terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0, < 6.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
#  profile = "AdministratorAccess-"
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "eks-vpc"
  cidr = "10.0.72.0/22"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets  = ["10.0.72.0/25", "10.0.72.128/25", "10.0.73.0/25"]
  private_subnets = ["10.0.73.128/25", "10.0.74.0/25", "10.0.74.128/25"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "Name" = "eks-vpc"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.29"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  cluster_endpoint_public_access = true

  # Grant full access to a user
  # Note: Admin permissions are handled through IAM roles and policies
  # The cluster creator will have access based on their AWS credentials

  eks_managed_node_groups = {
    default = {
      min_size     = 2
      max_size     = 4
      desired_size = 2

      instance_types = ["m5.large"]
      capacity_type  = "ON_DEMAND"
      subnet_ids     = module.vpc.private_subnets

      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AutoScalingFullAccess              = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
        ElasticLoadBalancingFullAccess     = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
        AmazonS3FullAccess                 = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
        AmazonVPCFullAccess                = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
        AmazonEC2FullAccess                = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
        AmazonRDSFullAccess                = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
      }
      
    }
  }

  # Enable necessary addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
    metrics-server = {
    most_recent = true
    }
  }
  tags = {
    "Project" = "eks-cluster"
  }

### Allow kubectl access from my IP

  cluster_security_group_additional_rules = {
    allow_kubectl_https = {
      type                     = "ingress"
      from_port               = 443
      to_port                 = 443
      protocol                = "tcp"
      cidr_blocks             = ["187.89.120.161/32"]
      description             = "Allow kubectl access from my IP"
    }
  }

}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

