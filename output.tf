output "blog_db_endpoint" {
  description = "RDS endpoint for Nancy's Blog"
  value       = aws_db_instance.nancy_blog_db.endpoint
}

output "blog_db_identifier" {
  description = "RDS instance identifier for Nancy's Blog"
  value       = aws_db_instance.nancy_blog_db.id
}

output "blog_target_group_arn" {
  description = "ARN of Nancy's Blog target group"
  value       = aws_lb_target_group.blog_tg.arn
}

output "blog_target_group_name" {
  description = "Name of Nancy's Blog target group"
  value       = aws_lb_target_group.blog_tg.name
}