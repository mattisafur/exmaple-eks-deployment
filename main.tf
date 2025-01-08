terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.82.2"
    }
  }
}

resource "aws_eks_cluster" "cluster" {
  name = var.cluster_name

  role_arn = data.aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = setunion(var.public_subnet_ids, var.private_subnet_ids)
  }

  upgrade_policy {
    support_type = var.support_type
  }
}

resource "aws_eks_fargate_profile" "fargate" {
  for_each = { for idx, val in var.fargate_profiles : val.name => val }

  cluster_name           = aws_eks_cluster.cluster.name
  pod_execution_role_arn = data.aws_iam_role.eks_fargate_profile_role.arn


  fargate_profile_name = each.value.name

  dynamic "selector" {
    for_each = each.value.selectors
    content {
      namespace = selector.value.namespace
      labels    = selector.value.labels
    }
  }
}

data "aws_iam_role" "eks_cluster_role" {
  name = "AmazonEKSAutoClusterRole"
}

data "aws_iam_role" "eks_fargate_profile_role" {
  name = "AmazonEKSFargatePodExecutionRole"
}
