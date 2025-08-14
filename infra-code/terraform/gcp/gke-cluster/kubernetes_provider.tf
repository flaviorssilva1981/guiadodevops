# Configure kubernetes provider using data from the created cluster
data "google_client_config" "default" {}

data "google_container_cluster" "target" {
  name     = module.gke.cluster_name
  location = module.gke.location
  project  = var.project_id
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.target.endpoint}"
  cluster_ca_certificate = base64decode(data.google_container_cluster.target.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}
