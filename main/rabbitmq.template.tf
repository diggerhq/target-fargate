
{% if environment_config.needs_rabbitmq is sameas True %}


resource "aws_security_group" "rabbitmq" {
  name_prefix = "${var.app}-${var.environment}-rabbitmq-sg"
  vpc_id = aws_vpc.vpc.id
  description = "RabbitMQ security group"

  # Only postgres in
  ingress {
    from_port = 5672
    to_port = 5672
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

resource "aws_mq_broker" "rabbitmq" {
  broker_name = "${var.app}-${var.environment}-rabbitmq"

  engine_type        = "RabbitMQ"
  engine_version     = "3.8.11"
  storage_type       = "ebs"
  host_instance_type = "mq.m5.large"
  security_groups    = [aws_security_group.rabbitmq.id]
  subnet_ids         = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id ]

  user {
    username = local.rabbitmq_username
    password = local.rabbitmq_password
  }
}

{% endif %}