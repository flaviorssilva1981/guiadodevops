variable "project_id"        { type = string }
variable "name"              { type = string }
variable "location"          { type = string }
variable "network"           { type = string }
variable "subnetwork"        { type = string }
variable "pods_range_name"   { type = string }
variable "services_range_name" { type = string }

variable "kubernetes_version" {
  type    = string
  default = null
}

variable "release_channel" {
  type    = string
  default = "REGULAR"
}

variable "enable_private_nodes" {
  type    = bool
  default = true
}

variable "enable_private_endpoint" {
  type    = bool
  default = false
}

variable "master_ipv4_cidr_block" {
  type    = string
  default = "172.16.0.0/28"
}

variable "logging_config" {
  type = object({
    enable_system_logs     = bool
    enable_workloads_logs  = bool
  })
  default = {
    enable_system_logs    = true
    enable_workloads_logs = true
  }
}

variable "monitoring_config" {
  type = object({
    enable_system_metrics     = bool
    enable_workloads_metrics  = bool
  })
  default = {
    enable_system_metrics    = true
    enable_workloads_metrics = true
  }
}

variable "workload_identity" {
  type    = bool
  default = true
}

variable "node_pools" {
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
      effect = string
    }))
  }))
}
