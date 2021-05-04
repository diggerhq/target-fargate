
  module "service-one" {
    source = "git::https://github.com/diggerhq/module-fargate-service.git?ref=v1.0.4"

    ecs_cluster = aws_ecs_cluster.app
    service_name = "svc-one"
    region = var.region
    service_vpc = aws_vpc.vpc
    # image_tag_mutability
    lb_subnet_a = aws_subnet.public_subnet_a
    lb_subnet_b = aws_subnet.public_subnet_b
    # lb_port
    # lb_protocol
    internal = false
    # deregistration_delay
    health_check = "/"
    # health_check_interval
    # health_check_timeout
    # health_check_matcher
    # lb_access_logs_expiration_days
    container_port = "8080"
    # replicas
    container_name = "zoko-dev-one"
    launch_type = "FARGATE"
    # ecs_autoscale_min_instances
    # ecs_autoscale_max_instances
    default_backend_image = "quay.io/turner/turner-defaultbackend:0.2.0"
    tags = var.tags
  }

  output "one_docker_registry" {
    value = module.service-one.docker_registry
  }

  output "one_lb_dns" {
    value = module.service-one.lb_dns
  }


