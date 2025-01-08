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
    subnet_ids = var.cluster_subnets
  }

  upgrade_policy {
    support_type = var.support_type
  }
}


data "aws_iam_role" "eks_cluster_role" {
  name = "AmazonEKSAutoClusterRole"
}
