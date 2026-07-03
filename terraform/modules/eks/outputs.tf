# The root module and github-oidc.tf consume these.
# We export everything the rest of the configuration needs.

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "HTTPS endpoint for the Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_arn" {
  description = "Full ARN of the EKS cluster — used when scoping IAM policies"
  value       = module.eks.cluster_arn
}

output "oidc_provider_arn" {
  description = "ARN of the cluster's OIDC provider — used for IRSA role trust policies"
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC provider without https:// prefix"
  value       = module.eks.oidc_provider
}

output "node_security_group_id" {
  description = "Security group attached to worker nodes — used to scope EFS/other SG rules"
  value       = module.eks.node_security_group_id
}