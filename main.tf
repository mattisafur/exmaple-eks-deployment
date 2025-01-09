terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.82.2"
    }
  }
}

data "aws_caller_identity" "identity" {}

resource "aws_eks_cluster" "cluster" {
  name = var.cluster_name

  role_arn = "arn:aws:iam::${data.aws_caller_identity.identity.account_id}:role/${var.cluster_role_name}"

  vpc_config {
    subnet_ids = setunion(var.public_subnet_ids, var.private_subnet_ids)
  }

  upgrade_policy {
    support_type = var.support_type
  }
}

resource "aws_eks_fargate_profile" "fargate" {
  for_each = { for idx, val in var.fargate_profiles : val.name => val }

  cluster_name = aws_eks_cluster.cluster.name

  pod_execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.identity.account_id}:role/${each.value.pod_execution_role_name}"
  fargate_profile_name   = each.value.name

  dynamic "selector" {
    for_each = each.value.selectors
    content {
      namespace = selector.value.namespace
      labels    = selector.value.labels
    }
  }
}
