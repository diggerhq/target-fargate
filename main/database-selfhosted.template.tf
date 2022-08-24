
# additional argument to support selfhosted
{% if environment_config.needs_postgres is sameas True and environment_config.rds_selfhosted %}

  resource "aws_security_group" "nsg_lb" {
    name        = "${var.app}-${var.environment}-rds-nsg-lbb"
    description = "Allow connections from external resources"
    vpc_id      = local.vpc.id

    tags = var.tags
  }


  resource "aws_security_group" "selfhosted_postgres" {
    name = "${var.app}-${var.environment}-rds-sg"
    vpc_id = local.vpc.id
    description = "RDS postgres selfhosted"

    # Only postgres in
    ingress {
      from_port = 5432
      to_port = 5432
      protocol = "tcp"
      security_groups = [aws_security_group.ecs_service_sg.id, aws_security_group.nsg_lb.id, aws_security_group.bastion_sg.id]
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

  resource "aws_lb" "selfhosted_db" {
    name               = "${var.app}-${var.environment}-db-lb"
    internal           = false
    load_balancer_type = "network"
    subnets            = [local.public_subnet_a.id, local.public_subnet_b.id]
    # security_groups    = [aws_security_group.nsg_lb.id]
    enable_deletion_protection = false

    tags = {
      Environment = var.environment
    }
  }

  resource "aws_lb_target_group" "test" {
    name_prefix     = "digger"
    port     = 5432
    protocol = "TCP"
    vpc_id   = local.vpc.id
  }

  resource "aws_lb_target_group_attachment" "test" {
    target_group_arn = aws_lb_target_group.test.arn
    target_id        = aws_instance.postgres.id
    port             = 5432
  }


  resource "aws_lb_listener" "postgres" {
    load_balancer_arn = aws_lb.selfhosted_db.arn
    port              = "5432"
    protocol          = "TCP"

    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.test.arn
    }
  }

  resource "aws_instance" "postgres" {
    subnet_id                   = local.public_subnet_a.id
    ami                         = "ami-0c2b8ca1dad447f8a"
    # key_name                    = aws_key_pair.bastion_key.key_name
    # {% if environment_config.rds_instance_type %}
      # instance_type             = "{{environment_config.rds_instance_type}}"
    # {% else %}
    # {% endif %}
    instance_type             = "t2.micro"
    
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.selfhosted_postgres.id]

    user_data = templatefile("../userdata/database_selfhosted.tpl", {
      database_password = local.database_password
    })

    tags = {
      Name = "${var.app}-${var.environment} postgres (selfhosted)"
    }
  }

  resource "random_password" "rds_password" {
    length           = 32
    special          = false
  }

  locals {
    database_address = aws_lb.selfhosted_db.dns_name
    database_name = "digger"
    database_username = "postgres"
    database_password = random_password.rds_password.result
    database_port = 5432
    database_url = "postgres://${local.database_username}:${local.database_password}@${local.database_address}:${local.database_port}/${local.database_name}"
    database_endpoint = "postgres://${local.database_username}:${local.database_password}@${local.database_address}:${local.database_port}/"
  }


  resource "aws_ssm_parameter" "database_password" {
    name = "${var.app}.${var.environment}.app_rds.database_password"
    value = local.database_password
    type = "SecureString"
  }

  # resource "aws_ssm_parameter" "database_url" {
  #   name = "${var.app}.${var.environment}.app_rds.database_url"
  #   value = local.database_url
  #   type = "SecureString"
  # }

  resource "aws_ssm_parameter" "database_endpoint" {
    name = "${var.app}.${var.environment}.app_rds.database_endpoint"
    value = local.database_endpoint
    type = "SecureString"
  }

  output "DGVAR_DATABASE_ENDPOINT" {
    value = local.database_endpoint
  }



{% endif %}