
{% if environment_config.needs_postgres is sameas True %}


    resource "aws_db_subnet_group" "rds_private_subnet_group" {
      name_prefix  = "rds_private_subnet_group"
      subnet_ids   = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id ]

      tags = {
        Name = "${var.app}-${var.environment}-rds-subnet-group"
      }
    }

  resource "aws_security_group" "rds" {
    name_prefix = "${var.app}-${var.environment}-rds-sg"
    vpc_id = local.vpc.id
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

  module "app_rds" {
    source = "../rds"
    
    {% if environment_config.rds_instance_type %}
    instance_class = "{{environment_config.rds_instance_type}}"
    {% endif %}
    
    {% if environment_config.rds_allocated_storage %}
    allocated_storage = "{{environment_config.rds_allocated_storage}}"    
    {% endif %}
    
    {% if environment_config.database_snapshot_identifier %}
    snapshot_identifier = "{{environment_config.database_snapshot_identifier}}"
    {% endif %}

    identifier_prefix = "${var.app}-${var.environment}"
    db_subnet_group_name = aws_db_subnet_group.rds_private_subnet_group.name
    vpc_security_group_ids = [aws_security_group.rds.id]
    publicly_accessible = false
  }

  locals {
    database_address = module.app_rds.database_address
    database_name = module.app_rds.database_name
    database_username = module.app_rds.database_username
    database_password = module.app_rds.database_password
    database_port = module.app_rds.database_port
    database_url = "postgres://${local.database_username}:${local.database_password}@${local.database_address}:${local.database_port}/${local.database_name}"
    database_endpoint = "postgres://${local.database_username}:${local.database_password}@${local.database_address}:${local.database_port}/"
  }

  resource "aws_ssm_parameter" "database_password" {
    name = "${var.app}.${var.environment}.app_rds.database_password"
    value = local.database_password
    type = "SecureString"
  }

  resource "aws_ssm_parameter" "database_url" {
    name = "${var.app}.${var.environment}.app_rds.database_url"
    value = local.database_url
    type = "SecureString"
  }

  resource "aws_ssm_parameter" "database_endpoint" {
    name = "${var.app}.${var.environment}.app_rds.database_endpoint"
    value = local.database_endpoint
    type = "SecureString"
  }

  output "DGVAR_DATABASE_URL" {
    value = aws_ssm_parameter.database_url.arn
  }


{% endif %}
