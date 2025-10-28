## AMI

variable "ami-jenkins" {
  default = "ami-097ce9a991bcbb4ec"
}


## Instance Type

variable "instance-type" {
  default = "m5.large"
}


# Subnet - Public 

variable "sub-public-01" {
default = "subnet-0936e00f3b79dfdda"
}

# Security Group - Public

variable "sg-public-01" {
default = "sg-0c4aa7eed6b25c050"
}

## EC2 Instance Name

variable "instance-name" {
  default = "MIG-Jenkins"
}

## Elastic Public IP Association
variable "eip_allocation_id" {
  type        = string
  default     = "eipalloc-01a7c02e3f53ff46c"
}