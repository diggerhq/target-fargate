
module "service-{{service_name}}" {
  source = "../fargate-service-module"

  ecs_cluster = aws_ecs_cluster.app
  service_name = "{{service_name}}"
  region = var.region
  service_vpc = aws_vpc.vpc
  service_security_groups = [aws_security_group.ecs_service_sg.id]
  # image_tag_mutability
  lb_subnet_a = aws_subnet.public_subnet_a
  lb_subnet_b = aws_subnet.public_subnet_b
  vpcCIDRblock = var.vpcCIDRblock
  # lb_port
  # lb_protocol
  internal = true
  # deregistration_delay
  health_check = "{{health_check}}"
  {% if environment_config.health_check_interval %}
  health_check_interval = "{{environment_config.health_check_interval}}"
  {% endif %}

  # health_check_timeout
  # health_check_matcher
  # lb_access_logs_expiration_days
  container_port = "{{container_port}}"
  # replicas
  container_name = "{{app_name}}-{{environment}}-{{service_name}}"
  launch_type = "{{launch_type}}"
  # ecs_autoscale_min_instances
  # ecs_autoscale_max_instances
  # lb_ssl_certificate_arn = "arn:aws:acm:eu-west-1:262499071169:certificate/411063e8-cd77-4498-921a-23adb15a1b9b"
  default_backend_image = "quay.io/turner/turner-defaultbackend:0.2.0"
  tags = var.tags
  zone = "lexiko.io."
  certificate_arn = var.certificate_arn
  domain = "{{service_name}}-{{environment}}.lexiko.io"
  cognito_user_pools_arn = var.cognito_user_pools_arn
  {% if task_cpu %}task_cpu = "{{task_cpu}}" {% endif %}
  {% if task_memory %}task_memory = "{{task_memory}}" {% endif %}
}

output "{{service_name}}_docker_registry" {
  value = module.service-{{service_name}}.docker_registry
}

output "{{service_name}}_lb_dns" {
  value = module.service-{{service_name}}.lb_dns
}

output "{{service_name}}_api_gateway_endpoint" {
  value = module.service-{{service_name}}.api_gateway_endpoint
}

