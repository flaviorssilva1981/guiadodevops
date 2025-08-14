variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "Default region for regional resources"
  default     = "us-central1"
}

variable "location" {
  type        = string
  description = "GKE location (region or zone). Example: us-central1"
  default     = "us-central1"
}

variable "network_name" {
  type        = string
  description = "Name of the VPC"
  default     = "vpc-gke"
}

variable "vpc_cidr" {
  type        = string
  description = "Primary VPC CIDR (for reference / firewall)"
  default     = "10.10.0.0/16"
}

variable "subnet_ip_cidr_range" {
  type        = string
  description = "Subnet primary CIDR for nodes"
  default     = "10.10.0.0/20"
}

variable "pods_secondary_cidr" {
  type        = string
  description = "Secondary range CIDR for Pods"
  default     = "10.20.0.0/14"
}

variable "services_secondary_cidr" {
  type        = string
  description = "Secondary range CIDR for Services"
  default     = "10.30.0.0/20"
}

variable "cluster_name" {
  type        = string
  description = "GKE cluster name"
  default     = "gke-primary"
}

variable "kubernetes_version" {
  type        = string
  description = "GKE version (blank = latest on channel)"
  default     = null
}

variable "release_channel" {
  type        = string
  description = "GKE release channel: RAPID | REGULAR | STABLE"
  default     = "REGULAR"
}

variable "enable_private_nodes" {
  type        = bool
  description = "Whether to use private nodes"
  default     = true
}

variable "enable_private_endpoint" {
  type        = bool
  description = "If true, control plane endpoint is internal only"
  default     = false
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "CIDR for the master authorized network/control plane (only when private)"
  default     = "172.16.0.0/28"
}

variable "logging_config" {
  type = object({
    enable_system_logs  = bool
    enable_workloads_logs = bool
  })
  default = {
    enable_system_logs    = true
    enable_workloads_logs = true
  }
}

variable "monitoring_config" {
  type = object({
    enable_system_metrics   = bool
    enable_workloads_metrics= bool
  })
  default = {
    enable_system_metrics    = true
    enable_workloads_metrics = true
  }
}

variable "workload_identity" {
  type        = bool
  description = "Enable Workload Identity (recommended)"
  default     = true
}

variable "node_pools" {
  description = "Map of node pool configs"
  type = map(object({
    machine_type   = string
    min_count      = number
    max_count      = number
    disk_size_gb   = number
    disk_type      = string
    preemptible    = bool
    spot           = bool
    auto_upgrade   = bool
    auto_repair    = bool
    tags           = list(string)
    labels         = map(string)
    taints         = list(object({
      key    = string
      value  = string
      effect = string # NO_SCHEDULE, PREFER_NO_SCHEDULE, NO_EXECUTE
    }))
  }))
  default = {
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
      labels       = {}
      taints       = []
    }
  }
}

variable "enable_apis" {
  type        = bool
  description = "Enable required Google APIs"
  default     = true
}
