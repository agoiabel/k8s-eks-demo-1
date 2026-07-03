# Variables are the inputs to our Terraform configuration.
# Separating variables from logic means the same files can be
# reused for dev/staging/prod by using different .tfvars files.

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Used as a prefix on all resource names to avoid collisions and make resources identifiable"
  type        = string
  default     = "nodejs-eks-demo"
}

variable "kubernetes_version" {
  description = <<EOT
EKS Kubernetes version. Must be within AWS standard support window
to avoid the 6x extended-support price increase.
Verify current versions at:
https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
  EOT
  type        = string
  default     = "1.34"
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "t3.small"
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes the cluster can scale to"
  type        = number
  default     = 3
}

variable "node_desired_size" {
  description = "Initial and target number of worker nodes"
  type        = number
  default     = 2
}

variable "github_org" {
  description = <<EOT
Your GitHub username or organization name.
Used to scope the OIDC trust policy so only YOUR repository can
assume the deployment IAM role — not any GitHub Actions workflow in the world.
  EOT
  type = string
}

variable "github_repo" {
  description = "GitHub repository name (not the full URL — just the repo name, e.g. 'nodejs-eks-demo')"
  type        = string
}

variable "create_oidc_provider" {
  description = "Set to false if the GitHub OIDC provider already exists in this AWS account"
  type        = bool
  default     = true
}