

resource "random_password" "rds_password" {
  length           = 32
  special          = false
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = var.db_subnet_group_ids

  tags = {
    Name = "My DB subnet group"
  }
}
resource "aws_db_instance" "default" {
  db_subnet_group_name = aws_db_subnet_group.default.name
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


output "DGVAR_LEXIKO_POSTGRESQL_HOST" {
  value = aws_db_instance.default.address
}

output "DGVAR_LEXIKO_POSTGRESQL_DB" {
  value = var.database_name
}

output "LEXIKO_POSTGRESQL_USER" {
  value = var.database_username
}

output "DGVAR_LEXIKO_POSTGRESQL_PASSWORD" {
  value = aws_db_instance.default.password
}

output "DGVAR_LEXIKO_POSTGRESQL_PORT" {
  value = 5432
}



