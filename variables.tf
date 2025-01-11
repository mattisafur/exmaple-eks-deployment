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
  # TODO validation: at least one subnet (public or private) is defined
}
variable "private_subnet_ids" {
  type    = set(string)
  default = []
  # TODO validation: at least one subnet (public or private) is defined
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

variable "support_type" {
  type    = string
  default = "EXTENDED"

  validation {
    condition     = contains(["STANDARD", "EXTENDED"], var.support_type)
    error_message = "Support type must be STANDARD or EXTENDED"
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
  # TODO validation (needed?): make sure name is unique
  # TODO validation: if subnet_ids not defined, at least one private subnet is define in var.private_subnet_ids
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
  # TODO validation (needed?): make sure name is unique
}
