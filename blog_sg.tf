resource "aws_security_group" "blog_db_sg" {
  name_prefix = "blog-db-sg-${var.env}-"
  description = "Database SG for Nancys Blog"
  vpc_id      = data.aws_vpc.blog_vpc.id

  # Dynamic ingress rules - HTTP, SSH, MySQL/Aurora, NFS
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "MySQL access"
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "NFS for EFS"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "blog-db-sg-${var.env}"
    Environment = var.env
    Application = "nancy-blog"
    OwnerEmail  = "nancytcheby@hotmail.com"
  }
}
