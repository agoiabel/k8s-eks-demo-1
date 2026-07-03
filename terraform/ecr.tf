# ECR (Elastic Container Registry) is AWS's private Docker image registry.
# Worker nodes pull images from here when starting pods.
# Using ECR instead of Docker Hub means:
# - Image pulls are free within the same region (no data transfer cost)
# - Images are private by default
# - Access is controlled by IAM — the same system managing everything else
resource "aws_ecr_repository" "app" {
  name = "${var.project_name}/app"

  # MUTABLE: allows pushing to the same tag multiple times.
  # :latest can be updated on every push.
  # IMMUTABLE would require unique tags on every push — better practice
  # for production traceability, but we handle this in the pipeline
  # by always tagging with the git SHA anyway.
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    # Automatically scans every pushed image against a CVE database.
    # Free, and surfaces vulnerabilities in the ECR console.
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-app"
  }
}

# Lifecycle policy: automatically delete images older than the
# most recent 10. Without this, every git push accumulates images
# in ECR indefinitely, quietly increasing storage costs.
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep the last 10 images, expire older ones"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}