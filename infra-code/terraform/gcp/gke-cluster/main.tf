# Optional: Enable required APIs (toggle via var.enable_apis)
resource "google_project_service" "required" {
  for_each = var.enable_apis ? toset([
    "container.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "artifactregistry.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ]) : []
  project                    = var.project_id
  service                    = each.key
  disable_dependent_services = false
}

module "network" {
  source = "./modules/network"

  project_id   = var.project_id
  network_name = var.network_name
  region       = var.region

  vpc_cidr               = var.vpc_cidr
  subnet_ip_cidr_range   = var.subnet_ip_cidr_range
  pods_secondary_cidr    = var.pods_secondary_cidr
  services_secondary_cidr= var.services_secondary_cidr
}

module "gke" {
  source = "./modules/gke"

  project_id         = var.project_id
  name               = var.cluster_name
  location           = var.location
  network            = module.network.network_self_link
  subnetwork         = module.network.subnet_self_link
  pods_range_name    = module.network.pods_range_name
  services_range_name= module.network.services_range_name

  release_channel    = var.release_channel
  kubernetes_version = var.kubernetes_version

  enable_private_nodes = var.enable_private_nodes
  enable_private_endpoint = var.enable_private_endpoint
  master_ipv4_cidr_block = var.master_ipv4_cidr_block

  logging_config     = var.logging_config
  monitoring_config  = var.monitoring_config

  workload_identity  = var.workload_identity

  node_pools = var.node_pools
}
