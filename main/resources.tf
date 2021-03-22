
resource "aws_security_group" "todolistdb" {
  # name = "platformdb"

  description = "RDS postgres servers (terraform-managed)"

  # Only postgres in
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "todolist-rds" {
  source = "../rds"
  vpc_security_group_ids = [aws_security_group.todolistdb.id]
  publicly_accessible = true
}


locals {
  database_address = module.todolist-rds.database_address
  database_name = module.todolist-rds.database_name
  database_username = module.todolist-rds.database_username
  database_password = module.todolist-rds.database_password
  database_port = module.todolist-rds.database_port
  # postgres://postgres:23q4RSDFSDFS@postgres:5432/postgres
  database_url = "postgres://${local.database_username}:${local.database_password}@${local.database_address}:${local.database_port}/${local.database_name}"
}

resource "aws_ssm_parameter" "database_password" {
  name = "${var.app}.${var.environment}.todolist-rds.database_password"
  value = local.database_password
  type = "SecureString"
}

resource "aws_ssm_parameter" "database_url" {
  name = "${var.app}.${var.environment}.todolist-rds.database_url"
  value = local.database_url
  type = "SecureString"
}

output "DGVAR_DATABASE_HOST" {
  value = local.database_address
}

output "DGVAR_DATABASE_DB" {
  value = local.database_name
}

output "DGVAR_DATABASE_USER" {
  value = local.database_username
}

output "DGVAR_DATABASE_PASSWORD" {
  value = aws_ssm_parameter.database_password.arn
  sensitive = true
}

output "DGVAR_DATABASE_URL" {
  value = aws_ssm_parameter.database_url.arn
  sensitive = true
}

output "DGVAR_DATABASE_PORT" {
  value = module.todolist-rds.database_port
}
