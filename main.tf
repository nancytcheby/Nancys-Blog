##########################################
# Random suffix for DB identifier (unique)
##########################################

resource "random_id" "blog_db_suffix" {
  byte_length = 4
}

##########################################
# RDS instance for Nancy's Blog
##########################################

resource "aws_db_instance" "nancy_blog_db" {
  identifier = format("nancy-blog-db-%s-%s", var.env, random_id.blog_db_suffix.hex)

  # Restore from snapshot
  snapshot_identifier = var.blog_db_snapshot_identifier
  instance_class      = var.blog_db_instance_class

  # Must match DB inside the snapshot
  username = var.blog_db_username
  password = var.blog_db_password

  # Use the existing DB subnet group
  db_subnet_group_name = var.blog_db_subnet_group_name

  # ONE shared SG for DB / EFS / ALB (class project, not prod)
  vpc_security_group_ids = [aws_security_group.blog_sg.id]

  skip_final_snapshot = true
  deletion_protection = false
  apply_immediately   = true

  tags = {
    Name        = format("nancy-blog-db-%s", var.env)
    Environment = var.env
    Application = "nancy-blog"
    OwnerEmail  = "nancytcheby@hotmail.com"
  }
}

##########################################
# Local tags and subnet IDs
##########################################

locals {
  blog_common_tags = {
    Project     = "nancy-blog"
    Environment = var.env
    Application = "nancy-blog"
    OwnerEmail  = "nancytcheby@hotmail.com"
  }

  # Use the PRIVATE subnets for EFS
  blog_efs_subnet_ids = data.aws_subnets.blog_private_subnets.ids

  # Public subnet IDs for ALB (replace with your actual subnet IDs)
  blog_alb_subnet_ids = [
    "subnet-0845a6847dc55232b",
    "subnet-0fdf3adafd8031d1e"
  ]
}

##########################################
# EFS for Nancy's Blog
##########################################

resource "aws_efs_file_system" "blog_efs" {
  creation_token   = "nancy-blog-efs-${var.env}"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = merge(local.blog_common_tags, {
    Name = "nancy-blog-efs-${var.env}"
  })
}

# One EFS mount target per private subnet
resource "aws_efs_mount_target" "blog_efs_mt" {
  count          = length(local.blog_efs_subnet_ids)
  file_system_id = aws_efs_file_system.blog_efs.id
  subnet_id      = local.blog_efs_subnet_ids[count.index]

  # Same SG shared for EFS
  security_groups = [aws_security_group.blog_sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

##########################################
# Target Group for Nancy's Blog
##########################################

resource "aws_lb_target_group" "blog_tg" {
  name     = "nancy-blog-tg-${var.env}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.blog_vpc.id

  health_check {
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    matcher             = "200-399"
  }

  tags = merge(local.blog_common_tags, {
    Name = "nancy-blog-tg-${var.env}"
  })
}

##########################################
# Application Load Balancer for Nancy's Blog
##########################################

resource "aws_lb" "blog_alb" {
  name               = "nancy-blog-alb-${var.env}"
  internal           = false
  load_balancer_type = "application"

  # Use the same SG (class project)
  security_groups = [aws_security_group.blog_sg.id]

  # Use dynamically selected subnet IDs
  subnets = local.blog_alb_subnet_ids

  tags = merge(local.blog_common_tags, {
    Name = "nancy-blog-alb-${var.env}"
  })
}

# Listener for HTTP traffic on port 80
resource "aws_lb_listener" "blog_http" {
  load_balancer_arn = aws_lb.blog_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blog_tg.arn
  }
}
