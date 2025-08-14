# Providers configured from variables
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# K8s provider configured after cluster creation using outputs (see kubernetes_provider.tf)
