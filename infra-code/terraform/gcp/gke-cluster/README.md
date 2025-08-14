# GKE on GCP with Terraform (modular)

This project creates a production-ready GKE cluster using Terraform **modules**,
with a **GCS remote backend**, **variables**, and **structured outputs**—mirroring
a modular approach similar to OKE on OCI.

## What it creates
- A dedicated VPC with subnets and secondary IP ranges for Pods and Services
- GKE cluster (private by default optional), regular release channel
- Managed node pool with autoscaling (configure min/max), or fixed size
- Opinionated logging/monitoring and security hardening (Shielded nodes, Workload Identity)
- IAM and API enablement (optional toggle)
- Outputs to fetch kubeconfig

## Prereqs
- Terraform >= 1.5
- gcloud CLI authenticated to the target project
- A GCS bucket for remote state (or use the provided `backend.hcl` + `terraform init -backend-config`)

## How to use
1. **Enable APIs** (or set `enable_apis = true` to let Terraform do it):
   ```bash
   gcloud services enable container.googleapis.com compute.googleapis.com iam.googleapis.com --project <YOUR_PROJECT_ID>
   ```

2. **Remote state** (recommended):
   - Create a GCS bucket (once):
     ```bash
     gsutil mb -p <YOUR_PROJECT_ID> -l <REGION> gs://<YOUR_BUCKET_NAME>
     ```
   - Edit `backend.hcl` with your bucket/prefix and run:
     ```bash
     terraform init -backend-config=backend.hcl
     ```

3. **Plan & apply**:
   ```bash
   terraform workspace new dev || terraform workspace select dev
   terraform plan -var-file=terraform.tfvars
   terraform apply -auto-approve -var-file=terraform.tfvars
   ```

4. **Get kubeconfig**:
   ```bash
   gcloud container clusters get-credentials $(terraform output -raw cluster_name)      --region $(terraform output -raw cluster_location)      --project $(terraform output -raw project_id)
   ```

## Destroy
```bash
terraform destroy -var-file=terraform.tfvars
```

## Notes
- Backend blocks **cannot use variables**. Use `backend.hcl` + `terraform init -backend-config=backend.hcl`.
- Adjust CIDRs carefully to avoid overlap with on‑prem/other clouds if you use hybrid networking.
