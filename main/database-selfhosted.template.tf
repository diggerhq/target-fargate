
# additional argument to support selfhosted
{% if environment_config.needs_postgres is sameas True and environment_config.rds_selfhosted %}

  resource "aws_security_group" "nsg_lb" {
    name_prefix = "postgres-lb-sg"
    description = "Allow connections from external resources"
    vpc_id      = local.vpc.id

    tags = var.tags
  }


  resource "aws_security_group" "selfhosted_postgres" {
    name_prefix = "${var.app}-${var.environment}-rds-sg"
    vpc_id = local.vpc.id
    description = "RDS postgres selfhosted"

    # Only postgres in
    ingress {
      from_port = 5432
      to_port = 5432
      protocol = "tcp"
      security_groups = [aws_security_group.ecs_service_sg.id, aws_security_group.nsg_lb, aws_security_group.bastion_sg.id]
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
    name_prefix        = "selfhosted-postgres"
    internal           = false
    load_balancer_type = "network"
    subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
    security_groups    = [aws_security_group.nsg_lb]
    enable_deletion_protection = false

    tags = {
      Environment = var.environment
    }
  }

  resource "aws_lb_target_group" "test" {
    name_prefix     = "digger"
    port     = 5432
    protocol = "tcp"
    vpc_id   = local.vpc.id
  }

  resource "aws_instance" "postgres" {
    subnet_id                   = aws_subnet.public_subnet_a.id
    ami                         = "ami-0c2b8ca1dad447f8a"
    # key_name                    = aws_key_pair.bastion_key.key_name
    {% if environment_config.rds_instance_type %}
      instance_type             = "{{environment_config.rds_instance_type}}"
    {% else %}
      instance_type             = "t2.micro"
    {% endif %}
    
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.selfhosted_postgres.id]

    user_data = templatefile("../userdata/database_selfhoosted.tpl", {})

    tags = {
      Name = "${var.app}-${var.environment} postgres (selfhosted)"
    }
  }


{% endif %}