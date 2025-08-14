resource "google_container_cluster" "this" {
  name     = var.name
  location = var.location
  network    = var.network
  subnetwork = var.subnetwork

  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = var.release_channel
  }

  dynamic "binary_authorization" {
    for_each = []
    content {}
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  workload_identity_config {
    workload_pool = var.workload_identity ? "${var.project_id}.svc.id.goog" : null
  }

  logging_config {
    enable_components = compact([
      var.logging_config.enable_system_logs ? "SYSTEM_COMPONENTS" : "",
      var.logging_config.enable_workloads_logs ? "WORKLOADS" : "",
    ])
  }

  monitoring_config {
    enable_components = compact([
      var.monitoring_config.enable_system_metrics ? "SYSTEM_COMPONENTS" : "",
      var.monitoring_config.enable_workloads_metrics ? "WORKLOADS" : "",
    ])
  }

  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  vertical_pod_autoscaling {
    enabled = true
  }

  lifecycle {
    ignore_changes = [node_config] # since we're using separate node_pools
  }
}

# Create one node pool per entry
resource "google_container_node_pool" "pools" {
  for_each = var.node_pools

  name       = "${var.name}-${each.key}"
  location   = var.location
  cluster    = google_container_cluster.this.name

  initial_node_count = max(each.value.min_count, 1)

  autoscaling {
    min_node_count = each.value.min_count
    max_node_count = each.value.max_count
  }

  management {
    auto_repair  = each.value.auto_repair
    auto_upgrade = each.value.auto_upgrade
  }

  node_config {
    machine_type = each.value.machine_type
    disk_size_gb = each.value.disk_size_gb
    disk_type    = each.value.disk_type

    preemptible  = each.value.preemptible
    spot         = each.value.spot

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    labels = each.value.labels
    tags   = each.value.tags

    dynamic "taint" {
      for_each = each.value.taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    shielded_instance_config {
      enable_secure_boot = true
    }
  }

  depends_on = [google_container_cluster.this]
}
