provider "aws" {
  region = var.aws_region

  # Assume the Engineer role in the DEV account
  assume_role {
    role_arn     = "arn:aws:iam::${lookup(var.accounts, var.env)}:role/Engineer"
    session_name = "terraform-blog-dev-session"
  }
}

# --- ADMIN / MGMT Account Provider (for SSM Parameter Store) ---
provider "aws" {
  alias  = "admin"
  region = var.PARAMETER_STORE_REGION

  assume_role {
    role_arn     = var.admin_ssm_role_arn
    session_name = "terraform-admin-ssm-session"
  }
}