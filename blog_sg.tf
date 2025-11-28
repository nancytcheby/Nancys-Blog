resource "aws_security_group" "blog_sg" {
  name_prefix = "blog-sg-${var.env}-"
  description = "Security group for Nancys Blog"  # no apostrophe!
  vpc_id      = data.aws_vpc.blog_vpc.id

  # HTTP for ALB / web
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }

  # SSH for admin access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # in real life: lock this down!
    description = "Allow SSH from anywhere"
  }

  # MySQL for DB
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # class project only
    description = "Allow MySQL traffic"
  }

  # NFS for EFS
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow NFS for EFS"
  }

  # All outbound traffic allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all egress"
  }

  tags = {
    Name        = "blog-sg-${var.env}"
    Environment = var.env
    Application = "nancy-blog"
    OwnerEmail  = "nancytcheby@hotmail.com"
  }
}

