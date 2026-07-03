# The actual values for this deployment.
# Terraform loads this file automatically because the name is exactly
# 'terraform.tfvars' — no flags required.
# For multiple environments you'd have separate files:
# dev.tfvars, staging.tfvars, prod.tfvars

aws_region         = "us-east-1"
project_name       = "k8s-eks-demo-1"
kubernetes_version = "1.34"
node_instance_type = "t3.small"
node_min_size      = 1
node_max_size      = 3
node_desired_size  = 2

# Replace these with your actual GitHub details
github_org  = "agoiabel"
github_repo = "k8s-eks-demo-1"

create_oidc_provider = true