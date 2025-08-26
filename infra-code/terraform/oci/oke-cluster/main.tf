module "oke_cluster" {
  source = "oracle-terraform-modules/oke/oci"
  version = "5.3.2" # Use the latest stable version

  providers = {
    oci = oci
    oci.home = oci
  }

  # General OCI parameters
  tenancy_ocid = var.tenancy_ocid
  compartment_id = var.compartment_ocid
  region         = var.region
  ssh_public_key_path = "/home/flavio/.ssh/oke_key3.pub"

  # OKE Cluster parameters
  cluster_name = var.cluster_name
  kubernetes_version = "v1.33.1" # Specify your desired Kubernetes version
  cluster_type = "enhanced"
  cni_type = "npn"

  # Network parameters (the module handles VCN, subnets, gateways, etc.)
  create_vcn = true
  vcn_cidrs = ["10.0.0.0/16"]

  # Worker pool configuration
  worker_pools = {
    "default-pool" = {
      size = 3
      shape = "VM.Standard.E4.Flex"
      ocpus = 2
      memory = 16
      boot_volume_size = 100
    }
  }

  # Bastion configuration - disable bastion host
  create_bastion = false

  # Public endpoint configuration
  control_plane_is_public = true
  assign_public_ip_to_control_plane = true
  
  # Allow public access to control plane (port 6443)
  control_plane_allowed_cidrs = ["0.0.0.0/0"]
  
  # Load Balancer configuration - Dynamic Shapes
  # This will apply to all Load Balancers created by OKE
  load_balancers = "both"
  preferred_load_balancer = "public"
  
  # Enable detailed outputs including kubeconfig
  output_detail = true
  
  # Install metrics-server manually after cluster creation
  metrics_server_install = false
}