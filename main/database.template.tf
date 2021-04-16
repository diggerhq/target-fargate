{% if environment_config.no_database is sameas True %}
{% else %}

  resource "aws_security_group" "db" {
    name_prefix = "${var.app}-${var.environment}-db-sg"
    vpc_id = aws_vpc.vpc.id
    description = "RDS postgres servers (terraform-managed)"

    # Only postgres in
    ingress {
      from_port = 5432
      to_port = 5432
      protocol = "tcp"
      security_groups = [aws_security_group.ecs_service_sg.id, aws_security_group.bastion_sg.id]
    }

    # Allow all outbound traffic.
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  module "rds" {
    source = "../rds"
    db_subnet_group_name = aws_db_subnet_group.private_subnet_group.name
    vpc_security_group_ids = [aws_security_group.db.id]
    publicly_accessible = false
  }

  locals {
    database_address = module.rds.database_address
    database_name = module.rds.database_name
    database_username = module.rds.database_username
    database_password = module.rds.database_password
    database_port = module.rds.database_port
    # postgres://postgres:23q4RSDFSDFS@postgres:5432/postgres
    database_url = "postgres://${local.database_username}:${local.database_password}@${local.database_address}:${local.database_port}/${local.database_name}"
  }

  # do not output secrets directly, but rather output a parameter
  # store value for them
  resource "aws_ssm_parameter" "database_password" {
    name = "${var.app}.${var.environment}.rds.database_password"
    value = local.database_password
    type = "SecureString"
  }

  resource "aws_ssm_parameter" "database_url" {
    name = "${var.app}.${var.environment}.rds.database_url"
    value = local.database_url
    type = "SecureString"
  }


{% endif %}