# Data sources read information from AWS without creating anything.
# We use them to avoid hardcoding values that might change.

# Current AWS account ID and region — used to build ARNs and URLs
# without hardcoding account numbers anywhere in the config.
data "aws_caller_identity" "current" {}

# Available AZs in our chosen region.
# Using a data source instead of hardcoding ["us-east-1a", "us-east-1b"]
# means the config works in any region automatically.
data "aws_availability_zones" "available" {
  state = "available"
}

# ─── VPC ──────────────────────────────────────────────────────────────────────
# Calls our own ./modules/vpc module, which internally uses the
# community terraform-aws-modules/vpc/aws.
# From here we only see the clean interface our module exposes.

module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  vpc_cidr     = "10.0.0.0/16"

  # Take the first 2 available AZs in whichever region we're deploying to.
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
}

# ─── EKS ──────────────────────────────────────────────────────────────────────
# Calls our own ./modules/eks module.
# Note how we pass vpc outputs directly to eks — Terraform
# builds a dependency graph from these references and applies
# resources in the right order automatically.

module "eks" {
  source = "./modules/eks"

  cluster_name       = var.project_name
  kubernetes_version = var.kubernetes_version

  # These come from the VPC module outputs — Terraform will create
  # the VPC first, then pass its outputs here.
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  node_instance_types = [var.node_instance_type]
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_desired_size   = var.node_desired_size
}