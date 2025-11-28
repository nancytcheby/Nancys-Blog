resource "random_id" "blog_db_suffix" {
  byte_length = 4
}

resource "aws_db_instance" "nancy_blog_db" {
  identifier = format("nancy-blog-db-%s-%s", var.env, random_id.blog_db_suffix.hex)

  # Restore from snapshot
  snapshot_identifier = var.blog_db_snapshot_identifier
  instance_class      = var.blog_db_instance_class

  username = var.blog_db_username
  password = var.blog_db_password

  db_subnet_group_name   = var.blog_db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.blog_db_sg.id]

  # Project usually doesn’t want final snapshots for labs
  skip_final_snapshot = true
  deletion_protection = false

  apply_immediately = true

  tags = {
    Name        = format("nancy-blog-db-%s", var.env)
    Environment = var.env
    Application = "nancy-blog"
    OwnerEmail  = "nancytcheby@hotmail.com"
  }
}

# ========================================
# EFS for Nancy's Blog
# ========================================

locals {
  # tags for Nancy's blog
  blog_common_tags = {
    Project     = "nancy-blog"
    Environment = var.env
    Application = "nancy-blog"
    OwnerEmail  = "nancytcheby@hotmail.com"
  }

  # use the same private subnets data source you already have
  blog_efs_subnet_ids = data.aws_subnets.blog_private_subnets.ids
}

# EFS file system
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

# One mount target per private subnet
resource "aws_efs_mount_target" "blog_efs_mt" {
  count          = length(local.blog_efs_subnet_ids)
  file_system_id = aws_efs_file_system.blog_efs.id
  subnet_id      = local.blog_efs_subnet_ids[count.index]

  # Re-use the same SG as the DB for now
  security_groups = [aws_security_group.blog_db_sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

# ========================================
# Target Group for Nancy's Blog
# ========================================

resource "aws_lb_target_group" "blog_tg" {
  name     = "nancy-blog-tg-${var.env}"
  port     = var.blog_tg_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.blog_vpc.id

  target_type = "instance"

  health_check {
    path                = var.blog_tg_health_check_path
    matcher             = "200-399"
    healthy_threshold   = 3
    unhealthy_threshold = 5
    timeout             = 10
    interval            = 60
    protocol            = "HTTP"
    port                = "traffic-port"
  }

  tags = merge(local.blog_common_tags, {
    Name = "nancy-blog-tg-${var.env}"
  })

  lifecycle {
    create_before_destroy = true
  }
}


