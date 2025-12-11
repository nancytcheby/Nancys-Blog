data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# Get default VPC (only used if create_custom_vpc = false)
data "aws_vpc" "blog_vpc" {
  count   = var.create_custom_vpc ? 0 : 1
  default = true
}

# Existing DB subnet group (only used if create_custom_vpc = false)
data "aws_db_subnet_group" "blog_db_subnet_group" {
  count = var.create_custom_vpc ? 0 : 1
  name  = var.blog_db_subnet_group_name
}

# Private subnets in default VPC (only used if create_custom_vpc = false)
data "aws_subnets" "blog_private_subnets" {
  count = var.create_custom_vpc ? 0 : 1

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.blog_vpc[0].id]
  }
}

# Public subnets for Nancy's Blog in default VPC (only used if create_custom_vpc = false)
data "aws_subnets" "blog_public_subnets" {
  count = var.create_custom_vpc ? 0 : 1

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.blog_vpc[0].id]
  }
  filter {
    name   = "tag:Tier"
    values = ["Public"]
  }
}

# Amazon Linux 2023 for Nancy's Blog
data "aws_ami" "blog_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Route53 hosted zone
data "aws_route53_zone" "blog" {
  name         = var.blog_hosted_zone_name
  private_zone = false
}

# ========================================
# Local Values for Resource Configuration
# ========================================

locals {
  # VPC ID - Use custom VPC if created, otherwise use default VPC
  vpc_id = var.create_custom_vpc ? aws_vpc.blog_vpc[0].id : data.aws_vpc.blog_vpc[0].id

  # Public Subnet IDs - Use custom subnets if created, otherwise use default VPC subnets or provided IDs
  public_subnet_ids = var.create_custom_vpc ? aws_subnet.blog_public_subnet[*].id : (
    length(var.alb_subnet_ids) > 0 ? var.alb_subnet_ids : (
      length(data.aws_subnets.blog_public_subnets) > 0 ? data.aws_subnets.blog_public_subnets[0].ids : var.blog_asg_subnet_ids
    )
  )

  # Private Subnet IDs - Use custom subnets if created, otherwise use public subnets
  private_subnet_ids = var.create_custom_vpc ? aws_subnet.blog_private_subnet[*].id : local.public_subnet_ids

  # ALB Subnet IDs (always public subnets)
  alb_subnet_ids = local.public_subnet_ids

  # EFS Subnet IDs - Use private subnets if in custom VPC, otherwise use ASG subnets
  efs_subnet_ids = var.create_custom_vpc ? local.private_subnet_ids : var.blog_asg_subnet_ids

  # ASG Subnet IDs - Use private subnets if in custom VPC, otherwise use provided or public subnets
  asg_subnet_ids = var.create_custom_vpc ? local.private_subnet_ids : var.blog_asg_subnet_ids

  # DB Subnet Group Name
  db_subnet_group_name = var.create_custom_vpc ? aws_db_subnet_group.blog_db_subnet_group[0].name : var.blog_db_subnet_group_name
}

