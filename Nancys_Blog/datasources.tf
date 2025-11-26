data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "blog_vpc" {
  default = true
}

# Existing DB subnet group for RDS
data "aws_db_subnet_group" "blog_db_subnet_group" {
  name = var.blog_db_subnet_group_name
}




