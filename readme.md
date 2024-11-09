# Exmaple Terraform EKS deployment
Terraform project that deploys an EKS cluster and base resources.

## variables
- `project_name` and `environment_name` - used for naming and tagging resources
- `cluster_iam_role_arn-` - used by the cluster to manage resources
- `vpc_cidr_block` - CIDR block to be assigned to the VPC
- `subnet_count` - number of subnets to create

## Resources
- VPC
- `subnet_count` public subnets in separate AZs
- `subnet_count` private subnets in separate AZs
- internet gateway
- public subnet routing table - routing traffic to internet gateway
- `subnet_count` NAT gateways in separate AZs routing traffic to the public subnets
- `subnet_count` elastic IPs for the NAT gateways
- `subnet_count` private subnet routing tables routing traffic to NAT gateway
- EKS cluster
