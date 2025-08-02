variable "region" {
  default = "sa-saopaulo-1"
}


variable "tenancy_ocid" {
  description = "ocid1.tenancy.oc1.."
  type        = string
}

variable "compartment_ocid" {
  description = "ocid1.compartment.oc1.."
  type        = string
}

variable "cluster_name" {
  default = "oke-cluster-devops01"
}

variable "kubernetes_version" {
  type        = string
  description = "Versão do Kubernetes"
  default     = "v1.33.1"
}

variable "node_image_id" {
  description = "Oracle-Linux-8.10"
  type        = string
  default     = "ocid1.image.oc1.sa-saopaulo-1."
}

variable "node_shape_id" {
  description = "Node Shape"
  type        = string
  default     = "VM.Standard.E3.Flex"
}

variable "services_cidr" {
  description = "CIDR block for Kubernetes services (OCI_VCN_IP_NATIVE mode)"
  type        = string
  default     = "10.240.0.0/16"
}

variable "pods_cidr" {
  description = "CIDR block for Kubernetes pods (OCI_VCN_IP_NATIVE mode)"
  type        = string
  default     = "10.241.0.0/16"
}
