# Outputs print after 'terraform apply' and are available
# via 'terraform output <name>' for use in scripts.

output "ecr_repository_url" {
  description = "Full ECR URL for docker push and k8s deployment manifests"
  value       = aws_ecr_repository.app.repository_url
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "configure_kubectl" {
  description = "Run this command to point kubectl at your EKS cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "github_actions_role_arn" {
  description = "Paste this value into GitHub repository secrets as AWS_ROLE_ARN"
  value       = aws_iam_role.github_actions.arn
}