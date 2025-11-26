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

variable "blog_db_snapshot_identifier" {
  description = "Snapshot ID for Nancys blog DB"
  type        = string
  # Example – replace with your actual snapshot name or ARN
  default     = "arn:aws:rds:us-east-1:083587468058:snapshot:wordpressnancyclixx"
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
  description = "RDS subnet group name for Nancy's blog"
  type        = string
  default     = "rds-ec2-db-subnet-group-1"  
}

variable "blog_db_security_group_id" {
  description = "Security Group ID to attach to Nancy's Blog RDS instance"
  type        = string
  default     = "sg-072c5b644d7ae1cca"      
}

variable "accounts" {
  description = "AWS account IDs per environment"
  type        = map(string)
  default = {
    dev  = "083587468058" 
    test = "111111111111" 
    uat  = "222222222222" 
  }
}