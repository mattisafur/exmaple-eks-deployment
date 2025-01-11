variable "global_cluster_tags" {
  type    = map(string)
  default = {}
}

variable "cluster_name" {
  type = string
}

variable "public_subnet_ids" {
  type    = set(string)
  default = []
}
variable "private_subnet_ids" {
  type    = set(string)
  default = []
}

variable "additional_cluster_security_group_ids" {
  type    = set(string)
  default = []
}

variable "cluster_role_name" {
  type    = string
  default = "AmazonEKSAutoClusterRole"
}

variable "kubernetes_version" {
  type    = string
  default = null
}

variable "cluster_log_types" {
  type    = set(string)
  default = []

  validation {
    condition = alltrue([
      for log_type in var.cluster_log_types :
      contains(["api", "audit", "authenticator", "controllerManager", "scheduler"], log_type)
    ])
    error_message = "The log types supported by AWS are api, audit, authenticator, controllerManager and scheduler"
  }
}

variable "support_type" {
  type    = string
  default = "EXTENDED"

  validation {
    condition     = contains(["STANDARD", "EXTENDED"], var.support_type)
    error_message = "Support type must be STANDARD or EXTENDED."
  }
}

variable "zonal_shift" {
  type    = bool
  default = false
}

variable "cluster_tags" {
  type = map(string)
}

variable "fargate_profiles" {
  type = set(object({
    name = string

    selectors = set(object({
      namespace = string

      labels = optional(map(string))
    }))

    pod_execution_role_name = optional(string)
    subnet_ids              = optional(set(string))
    tags                    = optional(map(string))
  }))
  default = []

  validation {
    condition     = length(distinct([for profile in var.fargate_profiles : profile.name])) == length(var.fargate_profiles)
    error_message = "Each fargate profile name must be unique."
  }
  validation {
    condition = alltrue([
      for profile in var.fargate_profiles :
      profile.subnet_ids != null || length(var.private_subnet_ids) > 1
    ])
    error_message = "If subnet_id is not defined in a fargate profile, at least one private subnet must be defined in private_subnet_ids."
  }
}

variable "node_groups" {
  type = set(object({
    name       = string
    subnet_ids = set(string)

    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })

    node_role_name = optional(string)
    tags           = optional(map(string))
  }))
  default = []

  validation {
    condition     = length(distinct([for group in var.node_groups : group.name])) == length(var.node_groups)
    error_message = "Each node group name must be unique."
  }
}
