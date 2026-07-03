variable "project_name" {
  description = "Used in resource names and tags"
  type        = string
}

variable "vpc_cidr" {
  description = "The IP range for the entire VPC. /16 gives 65,536 addresses to carve subnets from."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of AZ names to spread subnets across. Two AZs gives resilience without the cost of three."
  type        = list(string)
}