variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}
variable "environment_name" {
  description = "Project environemtn name for resource naming."
  type        = string
}

variable "cluster_iam_role_arn" {
  description = "IAM role ARN for EKS cluster."
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC."
  type        = string
}
variable "subnet_count" {
  description = "Number of public and private subnets to create."
  type        = number
  validation {
    condition     = var.subnet_count > 0
    error_message = "At least one public and private subnet must be created."
  }
  validation {
    condition     = length(data.aws_availability_zones.names)
    error_message = "Not enough availability zones are available in the selected region."
  }
}
