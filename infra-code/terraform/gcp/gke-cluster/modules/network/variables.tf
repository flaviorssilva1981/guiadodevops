variable "project_id" { type = string }
variable "network_name" { type = string }
variable "region" { type = string }

variable "vpc_cidr" { type = string }
variable "subnet_ip_cidr_range" { type = string }
variable "pods_secondary_cidr" { type = string }
variable "services_secondary_cidr" { type = string }
