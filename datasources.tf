data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# Use the default VPC in the account/region
data "aws_vpc" "blog_vpc" {
  default = true
}

# Public subnets (for ALB)
data "aws_subnets" "blog_public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.blog_vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*Public*"]
  }
}

# Private subnets (for EFS / EC2 / RDS)
data "aws_subnets" "blog_private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.blog_vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*Private*"]
  }
}

# Get all available AZs in the region

data "aws_availability_zones" "available" {
  state = "available"
}

# Get details for each public subnet
locals {
  public_subnet_ids = data.aws_subnets.blog_public_subnets.ids
}

data "aws_subnet" "subnet" {
  for_each = toset(local.public_subnet_ids)
  id       = each.value
}





