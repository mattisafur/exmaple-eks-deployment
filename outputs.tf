output "cluster" {
  value = aws_eks_cluster.cluster
}

output "fargate_profiles" {
  value = aws_eks_fargate_profile.fargate_profiles
}

output "node_groups" {
  value = aws_eks_node_group.node_groups
}
