output "blog_db_endpoint" {
  description = "RDS endpoint for Nancy's Blog"
  value       = aws_db_instance.nancy_blog_db.endpoint
}

output "blog_db_identifier" {
  description = "RDS instance identifier for Nancy's Blog"
  value       = aws_db_instance.nancy_blog_db.id
}

output "blog_key_pair_name" {
  description = "Name of the EC2 key pair for Nancy's Blog"
  value       = aws_key_pair.blog_key.key_name
}

output "blog_key_private_pem" {
  description = "Private key for Nancy's Blog EC2 key pair"
  value       = tls_private_key.blog_key.private_key_pem
  sensitive   = true
}

output "blog_asg_name" {
  description = "Name of the Auto Scaling Group for Nancy's Blog"
  value       = aws_autoscaling_group.blog_asg.name
}

output "blog_asg_arn" {
  description = "ARN of the Auto Scaling Group for Nancy's Blog"
  value       = aws_autoscaling_group.blog_asg.arn
}

output "blog_asg_desired_capacity" {
  description = "Desired capacity of the ASG for Nancy's Blog"
  value       = aws_autoscaling_group.blog_asg.desired_capacity
}

output "alb_dns" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.blog_alb.dns_name
}

output "efs_id" {
  description = "EFS File System ID"
  value       = aws_efs_file_system.blog_efs.id
}