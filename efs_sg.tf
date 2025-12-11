resource "aws_security_group" "blog_efs_sg" {
  name        = "nancy-blog-efs-sg-${var.env}"
  description = "SG for EFS mount targets for Nancy Blog"
  vpc_id      = local.vpc_id  # UPDATED: Use local.vpc_id instead of data.aws_vpc.blog_vpc.id

  # Allow EC2 SG to mount EFS
  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.blog_sg.id]
    description     = "Allow EC2 to mount EFS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "nancy-blog-efs-sg-${var.env}"
    Environment = var.env
    Application = "nancy-blog"
  }
}
