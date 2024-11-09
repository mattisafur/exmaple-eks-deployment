terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.75"
    }
  }
}

data "aws_availability_zones" "available_availability_zones" {}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.project_name}-${var.environment_name}-vpc"
  }
}

resource "aws_subnet" "public_subnets" {
  count = var.subnet_count

  vpc_id = aws_vpc.vpc.id

  cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, count.index)
  availability_zone = data.aws_availability_zones.available_availability_zones.names[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment_name}-public-subnet-${count.index}"
  }
}
resource "aws_subnet" "private_subnets" {
  count = var.subnet_count

  vpc_id = aws_vpc.vpc.id

  cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, 8 + count.index)
  availability_zone = data.aws_availability_zones.available_availability_zones.names[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment_name}-private-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-${var.environment_name}-gateway"
  }
}

resource "aws_eip" "nat_gateways" {
  count = var.subnet_count

  domain = "vpc"
}
resource "aws_nat_gateway" "nat_gateways" {
  count = var.subnet_count

  allocation_id = aws_eip.nat_gateways[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = {
    Name = "${var.project_name}-${var.environment_name}-nat-gateway-${count.index}"
  }

  depends_on = [aws_internet_gateway.gateway]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-${var.environment_name}-public-route-table"
  }
}
resource "aws_route_table_association" "public_subnets" {
  count = var.subnet_count

  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}
resource "aws_route" "public_to_internet_gateway" {
  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_route_table" "private_subnets" {
  count = var.subnet_count

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-${var.environment_name}-private-route-table-${count.index}"
  }
}
resource "aws_route_table_association" "private_subnets" {
  count = var.subnet_count

  route_table_id = aws_route_table.private_subnets[count.index].id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}
resource "aws_route" "private_subnets_to_nat_gateways" {
  count = var.subnet_count

  route_table_id = aws_route_table.private_subnets[count.index].id

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateways[count.index].id
}

resource "aws_eks_cluster" "cluster" {
  name     = "${var.project_name}-${var.environment_name}-cluster"
  role_arn = var.cluster_iam_role_arn

  vpc_config {
    subnet_ids         = aws_subnet.private_subnets[*].id
  }
}
