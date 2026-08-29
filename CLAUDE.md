# CLAUDE.md — guiadodevops

DevSecOps reference implementation: Terraform-provisioned clusters on 3 clouds,
GitOps with Argo CD app-of-apps, and a supporting tool stack (observability,
security, secrets, ingress, DNS, certs).

This file focuses on the two areas under active work — **`infra-code/`** (cluster
Terraform) and **`kubernetes/argocd_cluster02/`** (the Argo CD app-of-apps for the
OKE cluster) — and in particular the **OpenClaw + Claw3D** deployment built out
across PRs #170–#185.

---

## Repository layout

| Path | What it is |
|------|------------|
| `infra-code/terraform/aws/eks-cluster` | EKS 1.29, `terraform-aws-modules/eks` 19.21.0, S3 backend `fs-backend-terraforms` (us-east-1) |
| `infra-code/terraform/gcp/gke-cluster` | GKE, local `modules/network` + `modules/gke`, GCS backend via `backend.hcl` (placeholder values) |
| `infra-code/terraform/oci/oke-cluster` | **Live cluster for OpenClaw/Claw3D.** See below. |
| `kubernetes/argocd_cluster02/appofapps/` | Root Argo CD `Application` — recurses `applications/`, project `infra`, repo `github.com/flaviorssilva1981/guiadodevops` |
| `kubernetes/argocd_cluster02/applications/` | Child `Application` manifests, grouped: `core-tools/`, `tools/`, `istio/`, `boutique/`, `myapp/` |
| `kubernetes/argocd_cluster02/config/` | Raw manifests + Helm value bundles the child apps point at; Argo `AppProject`s in `config/projects-argocd/` (`infra`, `tools`, `core-tools`, `core-tools-config`, `my-app`) |
| `.github/workflows/ci-cd.yml` | App build (SonarQube gate → DockerHub → image-tag bump). **Only** fires on `config/my-k8s-app/**` — unrelated to OpenClaw. |
| `.github/workflows/gitops-validate.yml` | YAML lint on push to `main`/`dev` for `applications/`, `appofapps/`, `config/`. **This is the check that runs on OpenClaw PRs.** |

**Deploy model:** merge to `main` → Argo CD app-of-apps syncs automatically
(`prune: true`, `selfHeal: true`). There is no separate deploy pipeline for
GitOps changes.

**Cluster-wide primitives** (cluster02 / OKE): storageClass `oci-bv` (OCI block
volume), ingress class `nginx`, cert-manager cluster-issuer `letsencrypt`,
external-dns → Cloudflare (`cloudflare-proxied: "false"`), stakater `reloader`,
External Secrets Operator backed by Vault `ClusterSecretStore` named `vault`.

---

## OKE cluster (`infra-code/terraform/oci/oke-cluster`)

- Module `oracle-terraform-modules/oke/oci` **5.3.2**, Kubernetes **v1.33.1**, `cluster_type = enhanced`, CNI `npn`.
- Cluster name `oke-cluster-devops01`, region `sa-saopaulo-1`, VCN `10.0.0.0/16` (module-created).
- Worker pool: 3× `VM.Standard.E4.Flex` (2 OCPU / 16 GB, 100 GB boot).
- Control plane **public**, `control_plane_allowed_cidrs = ["0.0.0.0/0"]`, no bastion.
- Load balancers `both`, `preferred_load_balancer = public`.
- Backend: OCI object storage bucket `terraform-state-bucket`, namespace `gr5ugxwrsywe`, key `oke/terraform.tfstate`.
- Helper scripts (run after apply): `install-metrics-server.sh`, `apply-dynamic-lb.sh <svc>` (sets OCI flexible LB shape annotations).

---

## OpenClaw

Argo CD `Application` **`openclaw`** — `kubernetes/argocd_cluster02/applications/tools/openclaw.yaml`
(project `tools`, destination namespace **`ai-agents`**).

### Chart & versioning
- Helm chart `openclaw` pulled **directly from the community repo**
  `https://serhanekicii.github.io/openclaw-helm`, `targetRevision: 1.5.40`.
  This is a deliberate deviation from the cluster convention of mirroring charts
  into `harbor.guiadodevops.com/infra/*` (chart not mirrored yet — see the NOTE
  in the manifest; align later by mirroring `serhanekicii/openclaw-helm`).
- Chart wraps bjw-s **`app-template`**.
- `openclawVersion: "2026.7.1-2"` — pinned **forward** of the chart default
  (`2026.5.22`) because the in-cluster agent needs the memory-index schema from
  `2026.7.1-1` ("Memory Core startup repair").
- `configMode: merge` (**not** `overwrite`). The init-config deep-merge preserves
  the runtime `meta` block that Memory Core's startup-repair validates;
  `overwrite` copies a meta-less file, Memory Core rejects it on boot and
  "auto-restores from backup", which reverted every provider change. Consequence:
  **removed keys are never pruned from the live config** — see gotchas.
- `skills: []` — no ClawHub skills auto-installed (least-privilege).

### Pod shape
- **initContainer `fix-permissions`** runs as literal **root** (`runAsUser: 0`,
  `runAsNonRoot: false`) and does `chown 1000:1000 /home/node/.openclaw`. The PVC
  mount root was left root-owned from before the chart's non-root securityContext;
  k8s only chowns a volume root on fsGroup *mismatch*, so it was never fixed, and
  OpenClaw's exec tool `chmod`s that dir before every shell command → EPERM on
  every exec call. Non-root + `CAP_CHOWN` was tried first and failed the same way
  on this runtime.
- **main container**: `envFrom` secret `openclaw-env-secret`; resources bumped to
  `requests 500m / 1Gi`, `limits 4 CPU / 4Gi` — OpenClaw has **no horizontal
  scaling**, so the multi-agent roster's capacity comes from vertical sizing of
  the single gateway instance.
- **`lifecycle.postStart`** hook re-launches Claw3D on every pod start (see Claw3D
  section). Backgrounds via `setsid`, always `exit 0` (a non-zero postStart kills
  the container), no-ops if the installer dir is absent.
- `chromium` sub-container **disabled** — Telegram-only agent, cuts resource use
  and attack surface.

### Gateway config (`openclaw.json`)
Rendered from the chart's `configMaps.config`, but ConfigMap `openclaw` `/data`
is in `ignoreDifferences`, so Argo does not fight the runtime deep-merge.

- Gateway: port **18789**, `mode: local`, `trustedProxies: ["10.0.0.1"]`,
  `controlUi.allowedOrigins` includes `https://openclaw.dublinconsulting.com.br`.
- **Model provider: OpenAI `gpt-5.5`** (`openai/gpt-5.5`, `api: openai-responses`,
  key `${OPENAI_API_KEY}`). Provider history: Requesty → Anthropic direct (#176)
  → **OpenAI (#185, 2026-08-28)**. All 9 agents inherit `agents.defaults.model.primary`;
  no per-agent overrides.
- **Agent roster — "Time Chaves" (#180), 9 agents**: `chaves` (default), `chiquinha`,
  `dona-florinda`, `kiko`, `senhor-barriga`, `professor-girafales`, `seu-madruga`,
  `bruxa-do-71`, `chapolin`. Each `tools.profile: full`; mutual `subagents.allowAgents`
  + `tools.agentToAgent.enabled: true` (full mesh). Defaults: per-agent workspace on
  the PVC, `maxConcurrent: 3`, `timeoutSeconds: 600`.
- **`memorySearch.provider: "none"`** — FTS-only, vector store disabled. No
  embeddings key is provisioned; moving memory to OpenAI embeddings is a separate
  cost decision.
- Session: `scope: per-sender`, store on PVC, idle reset after 60 min.
- Channel: **Telegram** only (`${TELEGRAM_BOT_TOKEN}`). `web.search` disabled,
  `web.fetch` enabled.

### Services & Ingress (bjw-s app-template quirks)
- `service.main` has **`primary: true`** + `forceRename: openclaw`. Without
  `primary`, app-template renames every Service/Ingress to `openclaw-<identifier>`
  **and** repoints the main container's TCP probes from 18789 to the *other*
  service's port (3001) — nothing listens there, pod never goes Ready.
  `forceRename` pins the name so the change stays purely additive (no
  prune/recreate of the live gateway Service/Ingress, no TLS re-issue).
- `service.claw3d` → port **3001**, `controller: main`.
- `ingress.main` → **`openclaw.dublinconsulting.com.br`** (Control UI / gateway),
  nginx, `letsencrypt`, 3600s proxy read/send timeouts, TLS secret `openclaw-tls`.
- `ingress.claw3d` → **`3dclaw.dublinconsulting.com.br`**, TLS secret `claw3d-tls`.
- `persistence.data`: storageClass `oci-bv`, mounted at `/home/node/.openclaw`
  (also `advancedMounts` into the `fix-permissions` initContainer).
- `syncPolicy`: automated, `prune: true`, `selfHeal: true`, `CreateNamespace=true`.

### Secrets
`kubernetes/argocd_cluster02/config/tools/openclaw-config/external-secret.yaml`
(deployed by Argo `Application` **`openclaw-config`**):

- `ExternalSecret` `openclaw-env-secret` in `ai-agents`, `ClusterSecretStore`
  `vault`, `dataFrom.extract.key: openclaw` → Vault KV v2 at `secret/openclaw`,
  `refreshInterval: 15s`.
- Expected keys: `OPENAI_API_KEY` (Vault secret v5), `TELEGRAM_BOT_TOKEN`,
  `OPENCLAW_GATEWAY_TOKEN`.
- **Stale**: the in-file comment still lists `ANTHROPIC_API_KEY` / `REQUESTY_API_KEY`.
  Worth updating to `OPENAI_API_KEY` next time this file is touched.

---

## Claw3D  (github.com/iamlukethedev/Claw3D)

Claw3D Studio is a web UI that proxies to the OpenClaw gateway. **It is not part
of the OpenClaw chart** and has **no LLM of its own** (it talks to
`ws://localhost:18789`).

- Installed **once onto the PVC** at `/home/node/.openclaw/claw3d-openclaw-studio`;
  writable HOME at `/home/node/.openclaw/claw3d-home`.
- Runs as an **unmanaged `setsid` process inside the openclaw pod** — not a
  container, no Deployment. Binds `0.0.0.0:3001` (`HOST=0.0.0.0`,
  `TUNNEL_ENABLED=0` in `state/config.env`). The openclaw container declares no
  port 3001; the `openclaw-claw3d` Service targets the pod's 3001 directly.
- Fronted by the `claw3d` Service + Ingress → stable URL
  **`3dclaw.dublinconsulting.com.br`** (cluster nginx + cert-manager +
  external-dns), replacing the installer's throwaway `*.trycloudflare.com` quick
  tunnel whose hostname changed on every restart.
- Device pairing persists in `state/proxy-device.json` on the PVC.
- **Auto-start (#184)**: the openclaw container's `lifecycle.postStart` hook runs
  `claw3dctl start` on every pod start. Still **unsupervised** — if the process
  dies mid-pod-life it needs a manual
  `kubectl exec ... -- claw3dctl start`. Future work: move it to its own
  Deployment or a real sidecar container.

---

## Working conventions & gotchas

- **Config drift**: because `configMode: merge` + ConfigMap `/data` is in
  `ignoreDifferences`, editing `openclaw.json` in git **adds/overwrites** keys but
  never removes stale ones from the live PVC config. After a provider switch or
  key removal, `kubectl exec` into the pod and prune the old block by hand once
  (e.g. the leftover `anthropic` provider after #185).
- **Validate chart changes with `helm template`** (chart `openclaw` 1.5.40)
  before opening the PR.
- OpenClaw is single-instance — never add an HPA or replicas; scale the container
  resources instead.
- Branch → PR → merge to `main`. Argo CD `selfHeal` deploys on merge; the only CI
  gate is `gitops-validate.yml` (YAML lint).
- Guardrails (from the global persona): read before write; **ask before** any
  cloud mutation, `terraform apply`, commit, push, or `kubectl apply/delete`.
  Secrets live in Vault → External Secrets — never hardcode in manifests.
