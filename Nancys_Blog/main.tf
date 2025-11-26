resource "random_id" "blog_db_suffix" {
  byte_length = 4
}

resource "aws_db_instance" "nancy_blog_db" {
  identifier = format("nancy-blog-db-%s-%s", var.env, random_id.blog_db_suffix.hex)

  # Restore from snapshot
  snapshot_identifier = var.blog_db_snapshot_identifier
  instance_class      = var.blog_db_instance_class

  # These must match the DB inside the snapshot
  username = var.blog_db_username
  password = var.blog_db_password

 db_subnet_group_name   = var.blog_db_subnet_group_name
 vpc_security_group_ids = [var.blog_db_security_group_id]

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



