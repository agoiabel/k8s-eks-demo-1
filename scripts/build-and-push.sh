#!/usr/bin/env bash
set -euo pipefail

# Manual local build/push, for when you're not going through the CD
# pipeline (.github/workflows/cd.yml). Always builds both amd64 and
# arm64 so the image runs regardless of node architecture — a plain
# `docker build` on an Apple Silicon Mac only produces arm64 and
# fails to pull on amd64 EKS nodes (ImagePullBackOff).
#
# Usage: scripts/build-and-push.sh [tag]   (defaults to "v1")

AWS_REGION="${AWS_REGION:-us-east-1}"
TAG="${1:-v1}"

AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
IMAGE="${REGISTRY}/k8s-eks-demo-1/app:${TAG}"

aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "$REGISTRY"

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t "$IMAGE" \
  --push \
  "$(dirname "$0")/../app"

echo "Pushed $IMAGE"
