
{% if load_balancer %}
  module "service-{{service_name}}" {
    # make sure you version your modules and dendencies
    source = "git::https://github.com/diggerhq/module-fargate-service.git?ref=v1.0.5"

    ecs_cluster = aws_ecs_cluster.app
    service_name = "{{service_name}}"
    region = var.region
    service_vpc = aws_vpc.vpc
    service_security_groups = [aws_security_group.ecs_service_sg.id]
    lb_subnet_a = aws_subnet.public_subnet_a
    lb_subnet_b = aws_subnet.public_subnet_b
    internal = false
    health_check = "{{health_check}}"
    container_port = "{{container_port}}"
    container_name = "{{app_name}}-{{environment}}-{{service_name}}"
    launch_type = "{{launch_type}}"
    default_backend_image = "quay.io/turner/turner-defaultbackend:0.2.0"
    tags = var.tags
    {% if task_cpu %}task_cpu = "{{task_cpu}}" {% endif %}
    {% if task_memory %}task_memory = "{{task_memory}}" {% endif %}
  }

  output "{{service_name}}_docker_registry" {
    value = module.service-{{service_name}}.docker_registry
  }

  output "{{service_name}}_lb_dns" {
    value = module.service-{{service_name}}.lb_dns
  }


{% else %}
  module "service-{{service_name}}" {
    source = "../module-fargate-service-nolb"

    ecs_cluster = aws_ecs_cluster.app
    service_name = "{{service_name}}"
    region = var.region
    service_vpc = aws_vpc.vpc
    service_security_groups = [aws_security_group.ecs_service_sg.id]
    lb_subnet_a = aws_subnet.public_subnet_a
    lb_subnet_b = aws_subnet.public_subnet_b
    internal = false
    container_name = "{{app_name}}-{{environment}}-{{service_name}}"
    launch_type = "{{launch_type}}"
    default_backend_image = "quay.io/turner/turner-defaultbackend:0.2.0"
    tags = var.tags
    {% if task_cpu %}
    task_cpu = "{{task_cpu}}"
    {% endif %}
    {% if task_memory %}
    task_memory = "{{task_memory}}"
    {% endif %}
  }

  output "{{service_name}}_docker_registry" {
    value = module.service-{{service_name}}.docker_registry
  }

  output "{{service_name}}_lb_dns" {
    value = ""
  }

{% endif %}

