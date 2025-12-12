variable "aws_source_ami" {
  description = "Source AMI name pattern"
  default     = "al2023-ami-*-kernel-6.1-x86_64"  # Amazon Linux 2023 x86_64
}

variable "aws_instance_type" {
  description = "Instance type for building the AMI"
  default     = "t3.small"  # x86_64 instance
}

variable "ami_name" {
  description = "Name of the AMI to create"
  default     = "nancy-blog-ami-1"
}

variable "component" {
  description = "Component name for tagging"
  default     = "nancy-blog"
}

variable "aws_accounts" {
  description = "AWS account IDs to share the AMI with"
  type        = list(string)
  default = [
    "083587468058",  # Dev account
    "279271292861",  # Test account
    "818760291841",  # UAT account
    "767076727117"   # Prod account
  ]
}

variable "ami_regions" {
  description = "Regions to copy the AMI to"
  type        = list(string)
  default     = ["us-east-1"]
}

variable "aws_region" {
  description = "AWS region to build the AMI in"
  default     = "us-east-1"
}

# Get the latest Amazon Linux 2023 x86_64 AMI
data "amazon-ami" "source_ami" {
  most_recent = true
  owners      = ["amazon"]

  filters = {
    name                = "al2023-ami-*-kernel-6.1-x86_64"
    virtualization-type = "hvm"
    root-device-type    = "ebs"
    architecture        = "x86_64"
  }

  region = var.aws_region
}

# ------------------------------------------------------------------------------------
# EBS Builder Configuration
# ------------------------------------------------------------------------------------

source "amazon-ebs" "blog_ami" {
  ami_name      = "${var.ami_name}"
  ami_regions   = var.ami_regions
  ami_users     = var.aws_accounts
  snapshot_users = var.aws_accounts
  
  encrypt_boot  = false
  instance_type = var.aws_instance_type

  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/xvda"
    encrypted             = false
    volume_size           = 30
    volume_type           = "gp3"
  }

  region     = var.aws_region
  source_ami = data.amazon-ami.source_ami.id
  
  ssh_pty      = true
  ssh_timeout  = "10m"
  ssh_username = "ec2-user"

  tags = {
    Name        = "${var.ami_name}"
    Component   = "${var.component}"
    Environment = "shared"
    BuildDate   = "{{ timestamp }}"
    OS          = "Amazon Linux 2023"
    Architecture = "x86_64"
  }
}

# ------------------------------------------------------------------------------------
# Build Configuration
# ------------------------------------------------------------------------------------

build {
  sources = ["source.amazon-ebs.blog_ami"]

  # Install WordPress dependencies
  provisioner "shell" {
    inline = [
      "echo '======================================'",
      "echo 'Installing WordPress dependencies...'",
      "echo '======================================'",
      "sudo dnf update -y",
      
      # Install Apache, PHP, and MariaDB client
      "sudo dnf install -y httpd php php-fpm php-mysqlnd php-gd php-mbstring php-xml php-curl php-zip git",
      
      # Install NFS utils for EFS (amazon-efs-utils)
      "sudo dnf install -y amazon-efs-utils nfs-utils",
      
      # Install MariaDB client for database operations
      "sudo dnf install -y mariadb105",
      
      # Enable and start services
      "sudo systemctl enable httpd",
      "sudo systemctl enable php-fpm",
      
      # Create WordPress directory structure
      "sudo mkdir -p /var/www/html",
      
      # Set proper permissions
      "sudo chown -R apache:apache /var/www/html",
      "sudo chmod -R 755 /var/www/html",
      
      # Configure Apache - set DirectoryIndex
      "echo 'DirectoryIndex index.php index.html' | sudo tee /etc/httpd/conf.d/dir.conf",
      
      # Enable AllowOverride for .htaccess
      "sudo sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf",
      
      # Configure PHP
      "sudo sed -i 's/upload_max_filesize = .*/upload_max_filesize = 64M/' /etc/php.ini || true",
      "sudo sed -i 's/post_max_size = .*/post_max_size = 64M/' /etc/php.ini || true",
      "sudo sed -i 's/max_execution_time = .*/max_execution_time = 300/' /etc/php.ini || true",
      
      # Set SELinux booleans for httpd
      "sudo setsebool -P httpd_can_network_connect on || true",
      "sudo setsebool -P httpd_use_nfs on || true",
      
      "echo '======================================'",
      "echo 'Installation complete!'",
      "echo '======================================'",
    ]
  }

  # Create a health check endpoint
  provisioner "shell" {
    inline = [
      "echo '<?php http_response_code(200); echo \"OK\"; ?>' | sudo tee /var/www/html/health.php",
      "sudo chown apache:apache /var/www/html/health.php",
    ]
  }

  # Clean up
  provisioner "shell" {
    inline = [
      "echo 'Cleaning up...'",
      "sudo dnf clean all",
      "sudo rm -rf /tmp/*",
      "sudo rm -rf /var/tmp/*",
    ]
  }

  # Generate manifest file
  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
