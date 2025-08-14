output "project_id" {
  value       = var.project_id
  description = "GCP project id"
}

output "cluster_name" {
  value       = module.gke.cluster_name
  description = "GKE cluster name"
}

output "cluster_location" {
  value       = module.gke.location
  description = "GKE cluster location"
}

output "network_name" {
  value = module.network.network_name
}

output "subnet_name" {
  value = module.network.subnet_name
}
