
{% if load_balancer %}
  module "service-{{service_name}}" {
    source = "git::https://github.com/diggerhq/module-fargate-service.git?ref=v1.0.8"

    ecs_cluster = aws_ecs_cluster.app
    service_name = "{{service_name}}"
    region = var.region
    service_vpc = local.vpc
    service_security_groups = [aws_security_group.ecs_service_sg.id]
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

    {% if environment_config.lb_ssl_certificate_arn %}
      lb_ssl_certificate_arn = "{{environment_config.lb_ssl_certificate_arn}}"
    {% endif %}


    # for *.dggr.app listeners
    {% if environment_config.dggr_acm_certificate_arn %}
      dggr_acm_certificate_arn = "{{environment_config.dggr_acm_certificate_arn}}"
    {% endif %}


    {% if task_cpu %}task_cpu = "{{task_cpu}}" {% endif %}
    {% if task_memory %}task_memory = "{{task_memory}}" {% endif %}
  }

  {% if environment_config.create_dns_record %} 
    resource "aws_route53_record" "{{service_name}}_r53" {
      zone_id = "{{environment_config.dns_zone_id}}"
      name    = "{{environment}}-{{service_name}}.{{environment_config.hostname}}"
      type    = "A"

      alias {
        name                   = module.service-{{service_name}}.lb_dns
        zone_id                = module.service-{{service_name}}.lb_zone_id
        evaluate_target_health = false
      }
    }

    output "{{service_name}}_custom_domain" {
        value = aws_route53_record.{{service_name}}_r53.fqdn
    }

  {% endif %}


  # *.dggr.app domains
  {% if environment_config.use_dggr_domain %} 
    resource "aws_route53_record" "{{service_name}}_dggr_r53" {
      provider = aws.digger
      zone_id = "{{environment_config.dggr_zone_id}}"
      name    = "{{app_name}}-{{environment}}-{{service_name}}.{{environment_config.dggr_hostname}}"
      type    = "A"

      alias {
        name                   = module.service-{{service_name}}.lb_dns
        zone_id                = module.service-{{service_name}}.lb_zone_id
        evaluate_target_health = false
      }
    }

    output "{{service_name}}_dggr_domain" {
        value = aws_route53_record.{{service_name}}_dggr_r53.fqdn
    }
  {% endif %}

  output "{{service_name}}_docker_registry" {
    value = module.service-{{service_name}}.docker_registry
  }

  output "{{service_name}}_lb_dns" {
    value = module.service-{{service_name}}.lb_dns
  }

  output "{{service_name}}" {
    value = ""
  }

{% else %}
  module "service-{{service_name}}" {
    source = "../module-fargate-service-nolb"

    ecs_cluster = aws_ecs_cluster.app
    service_name = "{{service_name}}"
    region = var.region
    service_vpc = local.vpc
    # image_tag_mutability
    lb_subnet_a = aws_subnet.public_subnet_a
    lb_subnet_b = aws_subnet.public_subnet_b
    # lb_port
    # lb_protocol
    internal = false
    # replicas
    container_name = "{{app_name}}-{{environment}}-{{service_name}}"
    launch_type = "{{launch_type}}"
    # ecs_autoscale_min_instances
    # ecs_autoscale_max_instances
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

