# required_version pins the Terraform CLI itself.
# >= 1.10 specifically because 1.10 added native S3 state locking
# without needing a DynamoDB table — useful if you ever switch
# from local state to remote state later.
# We're using local state for this tutorial (simplest setup,
# single developer, no shared access needed).
terraform {
  required_version = ">= 1.10"

  required_providers {
    # The AWS provider is the plugin that translates Terraform resource
    # definitions into real AWS API calls. Terraform's core engine
    # knows nothing about AWS — the provider is what bridges that gap.
    # source = where to download it (the official Terraform Registry).
    # version ~> 5.0 = accept 5.x but reject a future breaking 6.x.
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# The provider block configures HOW the aws provider authenticates.
# We don't put credentials here — Terraform reads them from:
#   - Your local ~/.aws/credentials (from 'aws configure')
#   - Environment variables (AWS_ACCESS_KEY_ID, etc.)
#   - An IAM role if running on EC2 or in GitHub Actions (OIDC)
# Never hardcode credentials in Terraform files.
provider "aws" {
  region = var.aws_region

  # default_tags applies these tags to every single resource
  # Terraform creates in this configuration, automatically.
  # This means you can always find everything this config
  # created by filtering for Project = var.project_name in the console.
  default_tags {
    tags = {
      Project     = var.project_name
      ManagedBy   = "terraform"
      Environment = "production"
    }
  }
}