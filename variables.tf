variable "cluster_subnets" {
  description = "Subnets in which EKs will be deployed"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name for the created cluster. Other resources will have their names based on the cluster name."
  type        = string
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
