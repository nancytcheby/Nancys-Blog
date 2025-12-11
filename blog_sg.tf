resource "aws_security_group" "blog_sg" {
  name        = "nancy-blog-sg-${var.env}"
  description = "SG for Nancy Blog EC2"
  vpc_id      = local.vpc_id  

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MySQL (optional)
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # EC2 → allow outbound to EFS (handled via EFS SG)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "nancy-blog-sg-${var.env}"
    Environment = var.env
    Application = "nancy-blog"
  }
}

