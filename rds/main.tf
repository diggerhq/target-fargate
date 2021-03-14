

resource "random_password" "rds_password" {
  length           = 32
  special          = false
}

resource "aws_db_instance" "default" {
  allocated_storage    = var.allocated_storage
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  name                 = var.database_name
  username             = var.database_username
  password             = random_password.rds_password.result
  skip_final_snapshot  = true
  publicly_accessible  = var.publicly_accessible
  vpc_security_group_ids = var.vpc_security_group_ids

}

output  "vpc" {
  value = aws_db_instance.default.vpc
}

output "address" {
  value = aws_db_instance.default.address
}
