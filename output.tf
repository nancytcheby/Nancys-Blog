output "blog_db_endpoint" {
  description = "RDS endpoint for Nancy's Blog"
  value       = aws_db_instance.nancy_blog_db.endpoint
}

output "blog_db_identifier" {
  description = "RDS instance identifier for Nancy's Blog"
  value       = aws_db_instance.nancy_blog_db.id
}

output "blog_alb_dns_name" {
  description = "DNS name of Nancy's Blog ALB"
  value       = aws_lb.blog_alb.dns_name
}