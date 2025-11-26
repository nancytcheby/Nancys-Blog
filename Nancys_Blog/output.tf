output "blog_db_endpoint" {
  description = "RDS endpoint for Nancy's Blog"
  value       = aws_db_instance.nancy_blog_db.endpoint
}

output "blog_db_identifier" {
  description = "RDS instance identifier for Nancy's Blog"
  value       = aws_db_instance.nancy_blog_db.id
}
