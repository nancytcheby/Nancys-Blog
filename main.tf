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

  db_subnet_group_name   = local.db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.blog_sg.id]

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
  blog_common_tags = {
    Project     = "nancy-blog"
    Environment = var.env
    Application = "nancy-blog"
    OwnerEmail  = "nancytcheby@hotmail.com"
  }

  # Use ASG public subnets for EFS
  blog_efs_subnet_ids = local.efs_subnet_ids

  blog_bootstrap_user_data = templatefile("${path.module}/blog_bootstrap.sh", {
    aws_region = var.aws_region

    efs_id     = aws_efs_file_system.blog_efs.id
    lb_dns     = aws_lb.blog_alb.dns_name

    db_host    = aws_db_instance.nancy_blog_db.address
    db_name    = aws_db_instance.nancy_blog_db.db_name
    db_user    = var.blog_db_username
    db_pass    = var.blog_db_password
    BLOG_DOMAIN = var.blog_dns_record_name
  })

  blog_bootstrap_user_data_b64 = base64encode(local.blog_bootstrap_user_data)
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

# EFS mount targets for Nancy's Blog
resource "aws_efs_mount_target" "blog_efs_mt" {
  count          = length(local.blog_efs_subnet_ids)
  file_system_id = aws_efs_file_system.blog_efs.id
  subnet_id      = local.blog_efs_subnet_ids[count.index]

  # EFS SG
  security_groups = [aws_security_group.blog_efs_sg.id]

  lifecycle {
    create_before_destroy = true
  }
}



# ========================================
# Key pair for Nancy's Blog
# ========================================

# Generate an RSA private key
resource "tls_private_key" "blog_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Register the public key with AWS as an EC2 key pair
resource "aws_key_pair" "blog_key" {
  key_name   = var.blog_key_pair_name
  public_key = tls_private_key.blog_key.public_key_openssh

  tags = {
    Name        = var.blog_key_pair_name
    Environment = var.env
    Application = "nancy-blog"
    OwnerEmail  = "nancytcheby@hotmail.com"
  }
}

# ========================================
# Launch Template for Nancy's Blog
# ========================================

resource "aws_launch_template" "blog_lt" {
  name_prefix   = "nancy-blog-lt-${var.env}-"
  image_id      = data.aws_ami.blog_ami.id
  instance_type = var.blog_ec2_instance_type

  key_name = aws_key_pair.blog_key.key_name

  vpc_security_group_ids = [aws_security_group.blog_sg.id]

  user_data = local.blog_bootstrap_user_data_b64

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_access_profile.name
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(local.blog_common_tags, {
      Name = "nancy-blog-ec2-${var.env}"
    })
  }
}

# ========================================
# Auto Scaling Group for Nancy's Blog
# ========================================
resource "aws_autoscaling_group" "blog_asg" {
  name                      = "nancy-blog-asg-${var.env}"
  min_size                  = var.blog_asg_min_size
  max_size                  = var.blog_asg_max_size
  desired_capacity          = var.blog_asg_desired_capacity

  # Use hard-coded public subnet IDs
  vpc_zone_identifier = local.asg_subnet_ids

  target_group_arns         = [aws_lb_target_group.blog_tg.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 2400

  launch_template {
    id      = aws_launch_template.blog_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "nancy-blog-ec2-${var.env}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ========================================
# ALB Target Group for Nancy's Blog
# ========================================
resource "aws_lb_target_group" "blog_tg" {
  name     = "nancy-blog-tg-${var.env}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  health_check {
    path                = "/health.php"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "nancy-blog-tg-${var.env}"
    Environment = var.env
    Application = "nancy-blog"
    OwnerEmail  = "nancytcheby@hotmail.com"
  }
}

# ========================================
# Application Load Balancer for Nancy's Blog
# ========================================
resource "aws_lb" "blog_alb" {
  name               = "nancy-blog-alb-${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.blog_sg.id]
  subnets            = local.alb_subnet_ids

  tags = {
    Name        = "nancy-blog-alb-${var.env}"
    Environment = var.env
    Application = "nancy-blog"
    OwnerEmail  = "nancytcheby@hotmail.com"
  }
}

resource "aws_lb_listener" "blog_http" {
  load_balancer_arn = aws_lb.blog_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blog_tg.arn
  }
}

resource "aws_route53_record" "blog_dns" {
  zone_id = data.aws_route53_zone.blog.zone_id
  name    = var.blog_dns_record_name
  type    = "A"
  alias {
    name                   = aws_lb.blog_alb.dns_name
    zone_id                = aws_lb.blog_alb.zone_id
    evaluate_target_health = true
  }
}

