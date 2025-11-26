variable "aws_region" {
  description = "AWS region to deploy Nancy's Blog into"
  type        = string
  default     = "us-east-1"
}

variable "env" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "accounts" {
  description = "Map of environment to AWS account ID"
  type        = map(string)

  default = {
    dev = "083587468058"
  }
}
