# ─── OIDC PROVIDER ───────────────────────────────────────────────────────────
#
# The GitHub OIDC provider is account-level — only one can exist per
# AWS account regardless of how many projects you have.
#
# This file handles both cases cleanly:
#   - First project in this account → set create_oidc_provider = true
#     Terraform creates the provider.
#   - Second project (or after the collision you just hit) →
#     set create_oidc_provider = false in terraform.tfvars
#     Terraform reads the existing one instead.
#
# Either way, local.oidc_provider_arn always resolves to the correct ARN
# and everything below this block works identically in both cases.

# ── Case A: create the provider (create_oidc_provider = true) ──────────────
resource "aws_iam_openid_connect_provider" "github_actions" {
  # count = 1 when we want to create, count = 0 when we want to skip
  count = var.create_oidc_provider ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]

  tags = {
    Name = "${var.project_name}-github-oidc"
  }
}

# ── Case B: read the existing provider (create_oidc_provider = false) ───────
data "aws_iam_openid_connect_provider" "github_actions" {
  # count = 0 when we're creating (resource above handles it)
  # count = 1 when we're reading an existing one
  count = var.create_oidc_provider ? 0 : 1

  url = "https://token.actions.githubusercontent.com"
}

# ── Unified reference ────────────────────────────────────────────────────────
# Everything below this point references local.oidc_provider_arn —
# it doesn't matter whether we created it or read an existing one.
# The rest of the file never changes based on create_oidc_provider.
locals {
  oidc_provider_arn = var.create_oidc_provider ? (
    aws_iam_openid_connect_provider.github_actions[0].arn
  ) : (
    data.aws_iam_openid_connect_provider.github_actions[0].arn
  )
}

# ─── IAM ROLE FOR GITHUB ACTIONS ─────────────────────────────────────────────
resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = local.oidc_provider_arn
          # ↑ uses the local — works regardless of create_oidc_provider value
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-github-actions"
  }
}

# ─── ECR PERMISSIONS ─────────────────────────────────────────────────────────
resource "aws_iam_role_policy" "github_actions_ecr" {
  name = "ecr-push"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "GetAuthToken"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid    = "PushAndPull"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
          "ecr:DescribeImages",
        ]
        Resource = aws_ecr_repository.app.arn
      }
    ]
  })
}

# ─── EKS PERMISSIONS ─────────────────────────────────────────────────────────
resource "aws_iam_role_policy" "github_actions_eks" {
  name = "eks-describe"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DescribeCluster"
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster"]
        Resource = module.eks.cluster_arn
      }
    ]
  })
}

# ─── KUBERNETES RBAC ─────────────────────────────────────────────────────────
resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.github_actions.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_actions" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.github_actions.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type       = "namespace"
    namespaces = ["nodejs-demo"]
  }
}