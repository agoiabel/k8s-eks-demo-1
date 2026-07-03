# Provisions the EKS control plane and its managed node group via the
# upstream terraform-aws-modules/eks/aws module.
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids

  # Public API endpoint is required by the CI/CD and admin tooling that
  # reaches the cluster from outside the VPC.
  endpoint_public_access = true

  # Grants the Terraform-executing identity a cluster access entry with
  # admin permissions, so kubectl/helm work immediately after apply
  # without a separate aws-auth or access-entry step.
  enable_cluster_creator_admin_permissions = true

  # Module input name is `service_ipv4_cidr`, not `cluster_service_cidr`
  # (the latter is only an output). Must not overlap the VPC CIDR.
  service_ipv4_cidr = var.cluster_service_cidr

  # Without these, worker nodes boot and kubelet registers, but there's
  # no CNI plugin to set up pod networking — nodes stay NotReady forever
  # and the node group create fails with "Unhealthy nodes".
  # before_compute on vpc-cni ensures it's installed ahead of the node
  # group, so nodes have a network plugin from the moment they boot
  # instead of racing the node group and getting marked unhealthy.
  addons = {
    vpc-cni = {
      before_compute = true
    }
    kube-proxy = {}
    coredns    = {}
  }

  eks_managed_node_groups = {
    general = {
      instance_types = var.node_instance_types
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      desired_size   = var.node_desired_size

      labels = {
        role = "general"
      }
    }
  }
}