
module "service-{{service_name}}" {
  source = "git::https://github.com/diggerhq/module-fargate-service.git?ref=v1.0.3"

  ecs_cluster = aws_ecs_cluster.app
  service_name = "{{service_name}}"
  region = var.region
  service_vpc = aws_vpc.vpc
  # image_tag_mutability
  lb_subnet_a = aws_subnet.public_subnet_a
  lb_subnet_b = aws_subnet.public_subnet_b
  # lb_port
  # lb_protocol
  internal = false
  # deregistration_delay
  health_check = "{{health_check}}"
  # health_check_interval
  # health_check_timeout
  # health_check_matcher
  # lb_access_logs_expiration_days
  container_port = "{{container_port}}"
  # replicas
  container_name = "{{app_name}}-{{environment}}-{{service_name}}"
  launch_type = "{{launch_type}}"
  # ecs_autoscale_min_instances
  # ecs_autoscale_max_instances
  default_backend_image = "quay.io/turner/turner-defaultbackend:0.2.0"
  tags = var.tags
  # logs_retention_in_days
}

{% if service_name == "platform" %}

resource "aws_security_group" "platformdb" {
  name = "platformdb"

  description = "RDS postgres servers (terraform-managed)"
  vpc_id = aws_vpc.rds_vpc.id

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

module "{{service_name}}-rds" {
  source = "../rds"
  vpc_security_group_ids = [aws_security_group.platformdb.id]
}

{% endif %}


output "{{service_name}}_docker_registry" {
  value = module.service-{{service_name}}.docker_registry
}

output "{{service_name}}_lb_dns" {
  value = module.service-{{service_name}}.lb_dns
}
