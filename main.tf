terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.82.2"
    }
  }
}

check "subnet_validation" {
  assert {
    condition = length(var.public_subnet_ids) > 0 || length(var.private_subnet_ids) > 0
    error_message = "You must define at least one subnet (public or private)"
  }
}

data "aws_caller_identity" "identity" {}

resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = "arn:aws:iam::${data.aws_caller_identity.identity.account_id}:role/${var.cluster_role_name}"

  version = var.kubernetes_version
  tags    = merge(var.global_cluster_tags, var.cluster_tags)

  vpc_config {
    subnet_ids = setunion(var.public_subnet_ids, var.private_subnet_ids)

    security_group_ids = var.additional_cluster_security_group_ids
  }

  upgrade_policy {
    support_type = var.support_type
  }

  zonal_shift_config {
    enabled = var.zonal_shift
  }
}

resource "aws_eks_fargate_profile" "fargate_profiles" {
  for_each = { for profile in var.fargate_profiles : profile.name => profile }

  cluster_name = aws_eks_cluster.cluster.name

  fargate_profile_name   = each.value.name
  pod_execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.identity.account_id}:role/${coalesce(each.value.pod_execution_role_name, "AmazonEKSFargatePodExecutionRole")}"
  subnet_ids             = coalesce(each.value.subnet_ids, var.private_subnet_ids)

  tags = merge(var.global_cluster_tags, each.value.tags)

  dynamic "selector" {
    for_each = each.value.selectors

    content {
      namespace = selector.value.namespace
      labels    = selector.value.labels
    }
  }
}

resource "aws_eks_node_group" "node_groups" {
  for_each = { for group in var.node_groups : group.name => group }

  cluster_name = aws_eks_cluster.cluster.name

  node_group_name = each.value.name
  node_role_arn   = "arn:aws:iam::${data.aws_caller_identity.identity.account_id}:role/${coalesce(each.value.node_role_name, "AmazonEKSNodeRole")}"
  subnet_ids      = each.value.subnet_ids

  tags = merge(var.global_cluster_tags, each.value.tags)

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }
}
