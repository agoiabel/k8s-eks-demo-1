# Our module uses the well-maintained community VPC module internally.
# Writing a VPC from raw aws_vpc, aws_subnet, aws_route_table,
# aws_internet_gateway, aws_nat_gateway, and aws_route resources
# is 200+ lines of repetitive, easy-to-get-wrong Terraform.
# The community module handles all of it correctly.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs = var.availability_zones

  # Private subnets: where worker nodes live.
  # 'Private' means no direct inbound path from the internet.
  # Outbound traffic (pulling images, calling AWS APIs) goes through
  # the NAT gateway in the public subnet.
  # cidrsubnet(cidr, 8, N) carves /24 subnets from our /16.
  # If vpc_cidr = "10.0.0.0/16":
  #   cidrsubnet("10.0.0.0/16", 8, 1) = "10.0.1.0/24"
  #   cidrsubnet("10.0.0.0/16", 8, 2) = "10.0.2.0/24"
  # This approach is better than hardcoding "10.0.1.0/24" because
  # if vpc_cidr changes in terraform.tfvars, subnets recalculate correctly.
  private_subnets = [
    for i, az in var.availability_zones :
    cidrsubnet(var.vpc_cidr, 8, i + 1)
  ]

  # Public subnets: where internet-facing things live.
  # For us: the NAT gateway, and future LoadBalancer Services.
  # We offset by 101 to leave a clear gap between private and public
  # ranges, making the address space easy to reason about.
  public_subnets = [
    for i, az in var.availability_zones :
    cidrsubnet(var.vpc_cidr, 8, i + 101)
  ]

  # The NAT gateway provides outbound internet access for nodes
  # in private subnets. Without it, nodes can't pull images from ECR
  # or call AWS APIs.
  # single_nat_gateway = true means one NAT gateway shared across all
  # private subnets. One per AZ is more resilient but roughly doubles
  # the cost (~$32/month per NAT gateway). For this tutorial, one is fine.
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # These tags are required by EKS and the AWS Load Balancer Controller.
  # They're how Kubernetes knows which subnets to place load balancers in.
  # Without them, LoadBalancer-type Services will hang in Pending forever.
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}