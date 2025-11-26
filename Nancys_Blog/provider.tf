provider "aws" {
  region = var.aws_region

  # Assume the Engineer role in the DEV account
  assume_role {
    role_arn     = "arn:aws:iam::${lookup(var.accounts, var.env)}:role/Engineer"
    session_name = "terraform-blog-dev-session"
  }
}
