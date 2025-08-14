project_id = "your-project-id"
region    = "us-central1"
location  = "us-central1"

network_name = "vpc-gke"
vpc_cidr     = "10.10.0.0/16"

# Node subnet (nodes)
subnet_ip_cidr_range    = "10.10.0.0/20"
# Secondary ranges (pods/services)
pods_secondary_cidr     = "10.20.0.0/14"
services_secondary_cidr = "10.30.0.0/20"

cluster_name = "gke-primary"

# Example node pool config similar to OKE fixed pool (min=max=2)
node_pools = {
  default = {
    machine_type = "e2-standard-4"
    min_count    = 2
    max_count    = 2
    disk_size_gb = 100
    disk_type    = "pd-standard"
    preemptible  = false
    spot         = false
    auto_upgrade = true
    auto_repair  = true
    tags         = ["gke-nodes"]
    labels       = { "role" = "general" }
    taints       = []
  }
}
