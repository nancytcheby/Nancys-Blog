variable "env" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# ----------------------------------------
# AMI Configuration (for Packer)
# ----------------------------------------

variable "custom_ami_id" {
  description = "Custom AMI ID from Packer build (if empty, uses latest Amazon Linux 2023)"
  type        = string
  default     = ""
}

# ----------------------------------------
# VPC Configuration (NEW)
# ----------------------------------------

variable "create_custom_vpc" {
  description = "Whether to create custom VPC (true) or use default VPC (false)"
  type        = bool
  default     = true  # Set to false to use default VPC
}

variable "vpc_cidr" {
  description = "CIDR block for the custom VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (2 subnets for HA)"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (2 subnets for HA)"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

# ----------------------------------------
# Database Configuration
# ----------------------------------------

variable "blog_db_snapshot_identifier" {
  description = "Snapshot ID for Nancys blog DB"
  type        = string
  # Example – replace with your actual snapshot name or ARN
  default = "arn:aws:rds:us-east-1:083587468058:snapshot:wordpressnancyclixx"
}

variable "blog_db_instance_class" {
  description = "Instance class for Nancy's blog DB"
  type        = string
  default     = "db.t4g.micro"
}

variable "blog_db_username" {
  description = "DB username (must match snapshot)"
  type        = string
  default     = "annetcheby"
}

variable "blog_db_password" {
  description = "DB password (must match snapshot)"
  type        = string
  sensitive   = true
}

variable "blog_db_subnet_group_name" {
  description = "RDS subnet group name for Nancy's blog (only used if create_custom_vpc = false)"
  type        = string
  default     = "rds-ec2-db-subnet-group-1"
}

# ----------------------------------------
# Account Configuration
# ----------------------------------------

variable "accounts" {
  description = "AWS account IDs per environment"
  type        = map(string)
  default = {
    dev  = "083587468058"
    test = "279271292861"
    uat  = "818760291841"
    prod = "767076727117"
  }
}

# ----------------------------------------
# EFS Configuration
# ----------------------------------------

variable "blog_efs_name" {
  description = "Name for Nancy's blog EFS filesystem"
  type        = string
  default     = "nancy-blog-efs"
}

variable "blog_efs_subnet_ids" {
  description = "Optional override list of subnet IDs for Blog EFS mount targets (only used if create_custom_vpc = false)"
  type        = list(string)
  default     = []
}

# ----------------------------------------
# ALB Configuration
# ----------------------------------------

variable "alb_subnet_ids" {
  description = "List of subnet IDs for the Application Load Balancer (only used if create_custom_vpc = false)"
  type        = list(string)
  default     = []
}

# ----------------------------------------
# EC2 Configuration
# ----------------------------------------

variable "blog_key_pair_name" {
  description = "Key pair name for Nancy's Blog EC2 instances"
  type        = string
  default     = "nancy-blog-key-dev"
}

variable "blog_ec2_instance_type" {
  description = "EC2 instance type for Nancy's Blog"
  type        = string
  default     = "t3.micro"
}

# ----------------------------------------
# Auto Scaling Group Configuration
# ----------------------------------------

variable "blog_asg_min_size" {
  description = "Minimum number of blog EC2 instances"
  type        = number
  default     = 1
}

variable "blog_asg_max_size" {
  description = "Maximum number of blog EC2 instances"
  type        = number
  default     = 1
}

variable "blog_asg_desired_capacity" {
  description = "Desired number of blog EC2 instances"
  type        = number
  default     = 1
}

variable "blog_asg_subnet_ids" {
  description = "Subnet IDs where ASG instances launch (only used if create_custom_vpc = false)"
  type    = list(string)
  default = [
    "subnet-0a9d993807904fd0c",
    "subnet-0845a6847dc55232b",
    "subnet-0fdf3adafd8031d1e"
  ]
}

# ----------------------------------------
# DNS Configuration
# ----------------------------------------

variable "blog_dns_record_name" {
  description = "DNS record name for the blog (e.g. dev.blog.nancy-stack.com)"
  type        = string
  default     = "dev.blog.nancy-stack.com"
}

variable "blog_hosted_zone_name" {
  description = "Route53 hosted zone name (e.g. nancy-stack.com)"
  type        = string
  default     = "nancy-stack.com"
}

# ----------------------------------------
# SSM / Parameter Store Configuration
# ----------------------------------------

variable "PARAMETER_STORE_REGION" {
  default = "us-east-1"
}

variable "admin_ssm_role_arn" {
  description = "Role in admin account that EC2 and Terraform assume to access SSM"
  type        = string
  default     = "arn:aws:iam::135576900189:role/TerraformSSMRole"
}