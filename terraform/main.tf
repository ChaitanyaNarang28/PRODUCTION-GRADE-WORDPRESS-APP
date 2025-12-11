locals {
  name_prefix = var.project_name
}

# -------------------------------
# VPC MODULE
# -------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name               = "${local.name_prefix}-vpc"
  cidr               = var.vpc_cidr
  azs                = var.azs

  public_subnets  = [for idx, az in var.azs : cidrsubnet(var.vpc_cidr, 8, idx)]
  private_subnets = [for idx, az in var.azs : cidrsubnet(var.vpc_cidr, 8, idx + length(var.azs))]

  enable_nat_gateway = true
  single_nat_gateway = false

  tags = {
    Project = local.name_prefix
  }
}


# EKS MODULE

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.0"

  cluster_name    = "${local.name_prefix}-eks"
  cluster_version = "1.29"

  # EKS WILL USE PRIVATE SUBNETS FOR NODES
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    instance_types = var.node_group_instance_types
  }

  eks_managed_node_groups = {
    default = {
      desired_size = var.desired_workers
      min_size     = 1
      max_size     = var.desired_workers + 2
    }
  }

  
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access_cidrs = ["65.0.110.53/32"]

    access_entries = {
    root-admin = {
      principal_arn = "arn:aws:iam::025066248529:root"
      type          = "STANDARD"

      policy_associations = {
        admin = {
          # grants cluster-admin-like access via the module's managed association
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = {
    Project = local.name_prefix
  }
}
