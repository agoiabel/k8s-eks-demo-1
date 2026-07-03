# These outputs are what the root module and EKS module
# consume. We only expose what's actually needed.

output "vpc_id" {
  description = "ID of the VPC — passed to the EKS module"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets — where EKS worker nodes run"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "IDs of the public subnets — where load balancers are created"
  value       = module.vpc.public_subnets
}