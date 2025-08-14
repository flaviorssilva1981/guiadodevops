# Remote state backend config for Terraform (use with: terraform init -backend-config=backend.hcl)
bucket = "YOUR_GCS_BACKEND_BUCKET_NAME"
prefix = "terraform/state/gke"
# Optionally:
# impersonate_service_account = "tf-backend@YOUR_PROJECT_ID.iam.gserviceaccount.com"
