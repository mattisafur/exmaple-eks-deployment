variable "public_subnet_ids" {
  description = "Public subnets for EKS"
  type        = set(string)
}
variable "private_subnet_ids" {
  description = "Private subnets for EKS"
  type        = set(string)
}

variable "cluster_name" {
  description = "Name for the created cluster. Other resources will have their names based on the cluster name."
  type        = string
}

variable "cluster_role_name" {
  description = "IAM role to be used by the cluster"
  type = string
  default = "AmazonEKSAutoClusterRole"
}

variable "support_type" {
  description = "Kubernetes cluster support type. can be set to EXTENDED or STANDARD."
  type        = string
  default     = "EXTENDED"
  validation {
    condition     = contains(["EXTENDED", "STANDARD"], var.support_type)
    error_message = "Invalid value"
  }
}

variable "fargate_profiles" {
  description = "List of fargate profiles to be created."
  type = list(object({
    name                    = string
    pod_execution_role_name = optional(string)
    selectors = list(object({
      namespace = optional(string)
      labels    = optional(map(string))
    }))
  }))
  default = []
  # TODO add name uniqueness validation
  # TODO add validation for selector's contents
  # TODO require at least one selector for each profile
}
