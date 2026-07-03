variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS control plane"
  type        = string
}

variable "vpc_id" {
  description = "VPC to place the cluster in — output from the VPC module"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for worker nodes — output from the VPC module"
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types for worker nodes"
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 3
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "cluster_service_cidr" {
  description = "Kubernetes service CIDR — must match what EKS assigned to the cluster"
  type        = string
  default     = "172.20.0.0/16"
}