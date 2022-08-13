
module "monitoring-{{service_name}}-mem-cpu" {
  count = var.monitoring_enabled ? 1 : 0
  source = "./cpu_mem_monitoring"
  ecs_cluster_name = aws_ecs_cluster.app.name
  ecs_service_name = "{{service_name}}"
  alarms_sns_topic_arn = var.alarms_sns_topic_arn
  tags = var.tags
}

{% if environment_config.tcp_service %}
  
  module "service-{{service_name}}" {
    source = "../fargate-service-tcp"

    ecs_cluster = aws_ecs_cluster.app
    service_name = "{{service_name}}"
    region = var.region
    service_vpc = aws_vpc.vpc
    service_security_groups = [aws_security_group.ecs_service_sg.id]
    # image_tag_mutability

    {% if environment_config.use_subnets_cd %}
      lb_subnet_a = aws_subnet.public_subnet_c
      lb_subnet_b = aws_subnet.public_subnet_d      
    {% else %}
      lb_subnet_a = aws_subnet.public_subnet_a
      lb_subnet_b = aws_subnet.public_subnet_b
    {% endif %}

    vpcCIDRblock = var.vpcCIDRblock
    # lb_port
    # lb_protocol

    # override by environmentconfig but also possible to have service internal be true
    {% if environment_config.internal is sameas True %}
      internal = true
    {% elif internal is sameas True %}
      internal = true
    {% else %}
      internal = false
    {% endif %}

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
    {% if task_cpu %}task_cpu = "{{task_cpu}}" {% endif %}
    {% if task_memory %}task_memory = "{{task_memory}}" {% endif %}

    {% if environment_config.include_efs_volume %}
      volumes = [
        {
          name = "${var.app}_${var.environment}_{{service_name}}_{{environment_config.efs_volume_name}}"
          file_system_id = module.{{service_name}}_efs_mount.fs_id
        }
      ]

      mountPoints = [{
        path = "{{environment_config.efs_volume_path}}"
        volume = "${var.app}_${var.environment}_{{service_name}}_{{environment_config.efs_volume_name}}"
      }]

    {% endif %}
  }

  
  {% if environment_config.include_efs_volume %}
    module "{{service_name}}_efs_mount" {
      source = "../efs_mount"
      service_name = "${var.app}_${var.environment}_{{service_name}}_{{environment_config.efs_volume_name}}"
      vpc_id = local.vpc.id
      {% if environment_config.use_subnets_cd %}
        subnet_a_id = aws_subnet.public_subnet_c.id
        subnet_b_id = aws_subnet.public_subnet_d.id
      {% else %}
        subnet_a_id = aws_subnet.public_subnet_a.id
        subnet_b_id = aws_subnet.public_subnet_b.id
      {% endif %}
      ecs_securitygroup_id = aws_security_group.ecs_service_sg.id
    }
  {% endif %}


  output "{{service_name}}_docker_registry" {
    value = module.service-{{service_name}}.docker_registry
  }

  output "{{service_name}}_lb_dns" {
    value = module.service-{{service_name}}.lb_dns
  }

  output "{{service_name}}_task_security_group_id" {
    value = module.service-{{service_name}}.task_security_group_id
  }

{% elif load_balancer %}
  module "service-{{service_name}}" {
    source = "../module-fargate-service"

    ecs_cluster = aws_ecs_cluster.app
    service_name = "{{service_name}}"
    region = var.region
    service_vpc = local.vpc
    service_security_groups = [aws_security_group.ecs_service_sg.id]
    # image_tag_mutability

    {% if environment_config.use_subnets_cd %}
      lb_subnet_a = aws_subnet.public_subnet_c
      lb_subnet_b = aws_subnet.public_subnet_d      
    {% else %}
      lb_subnet_a = aws_subnet.public_subnet_a
      lb_subnet_b = aws_subnet.public_subnet_b
    {% endif %}

    # lb_port
    # lb_protocol

    # override by environmentconfig but also possible to have service internal be true
    {% if environment_config.internal is sameas True %}
      internal = true
    {% elif internal is sameas True %}
      internal = true
    {% else %}
      internal = false
    {% endif %}

    # deregistration_delay
    health_check = "{{health_check}}"

    {% if environment_config.health_check_disabled %}
    health_check_enabled = false
    {% endif %}

    {% if environment_config.health_check_grace_period_seconds %}
    health_check_grace_period_seconds = "{{environment_config.health_check_grace_period_seconds}}"
    {% endif %}

    {% if environment_config.lb_protocol %}
    lb_protocol = "{{environment_config.lb_protocol}}"
    {% endif %}

    {% if health_check_matcher %}
    health_check_matcher = "{{health_check_matcher}}"
    {% endif %}

    {% if environment_config.ecs_autoscale_min_instances %}
      ecs_autoscale_min_instances = "{{environment_config.ecs_autoscale_min_instances}}"
    {% endif %}

    {% if environment_config.ecs_autoscale_max_instances %}
      ecs_autoscale_max_instances = "{{environment_config.ecs_autoscale_max_instances}}"
    {% endif %}

    container_port = "{{container_port}}"
    container_name = "{{app_name}}-{{environment}}-{{service_name}}"
    launch_type = "{{launch_type}}"
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

    {% if environment_config.include_efs_volume %}
      volumes = [
        {
          name = "${var.app}_${var.environment}_{{service_name}}_{{environment_config.efs_volume_name}}"
          file_system_id = module.{{service_name}}_efs_mount.fs_id
        }
      ]

      mountPoints = [{
        path = "{{environment_config.efs_volume_path}}"
        volume = "${var.app}_${var.environment}_{{service_name}}_{{environment_config.efs_volume_name}}"
      }]

    {% endif %}
  }

  module "monitoring-{{service_name}}-elb" {
    count = var.monitoring_enabled ? 1 : 0
    source = "./lb_monitoring"
    ecs_cluster_name = aws_ecs_cluster.app.name
    ecs_service_name = "{{service_name}}"
    alarms_sns_topic_arn = var.alarms_sns_topic_arn
    target_group_arn_suffix = module.service-{{service_name}}.target_group_arn_suffix
    alb_arn_suffix = module.service-{{service_name}}.alb_arn_suffix

    {% if environment_config.disable_target_response_time_average_high_alarm is defined %}
    disable_target_response_time_average_high_alarm={{ environment_config.disable_target_response_time_average_high_alarm }}
    {% endif %}
    {% if environment_config.disable_httpcode_elb_5xx_count_high_alarm is defined %}
    disable_httpcode_elb_5xx_count_high_alarm={{ environment_config.disable_httpcode_elb_5xx_count_high_alarm }}
    {% endif %}
    {% if environment_config.disable_httpcode_target_5xx_count_high_alarm is defined %}
    disable_httpcode_target_5xx_count_high_alarm={{ environment_config.disable_httpcode_target_5xx_count_high_alarm }}
    {% endif %}
    {% if environment_config.disable_httpcode_target_4xx_count_high_alarm is defined %}
    disable_httpcode_target_4xx_count_high_alarm={{ environment_config.disable_httpcode_target_4xx_count_high_alarm }}
    {% endif %}
    {% if environment_config.disable_httpcode_target_3xx_count_high_alarm is defined %}
    disable_httpcode_target_3xx_count_high_alarm={{ environment_config.disable_httpcode_target_3xx_count_high_alarm }}
    {% endif %}

    tags = var.tags
  }

  
  {% if environment_config.include_efs_volume %}
    module "{{service_name}}_efs_mount" {
      source = "../efs_mount"
      service_name = "${var.app}_${var.environment}_{{service_name}}_{{environment_config.efs_volume_name}}"
      vpc_id = local.vpc.id
      {% if environment_config.use_subnets_cd %}
        subnet_a_id = aws_subnet.public_subnet_c.id
        subnet_b_id = aws_subnet.public_subnet_d.id
      {% else %}
        subnet_a_id = aws_subnet.public_subnet_a.id
        subnet_b_id = aws_subnet.public_subnet_b.id
      {% endif %}
      ecs_securitygroup_id = aws_security_group.ecs_service_sg.id
    }
  {% endif %}

  {% if environment_config.create_dns_record != "false" %} 
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

  output "{{service_name}}_task_security_group_id" {
    value = module.service-{{service_name}}.task_security_group_id
  }

  output "{{service_name}}_lb_arn" {
    value = module.service-{{service_name}}.lb_arn
  }

  output "{{service_name}}_lb_http_listener_arn" {
    value = module.service-{{service_name}}.lb_http_listener_arn
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

    {% if environment_config.use_subnets_cd %}
      lb_subnet_a = aws_subnet.public_subnet_c
      lb_subnet_b = aws_subnet.public_subnet_d      
    {% else %}
      lb_subnet_a = aws_subnet.public_subnet_a
      lb_subnet_b = aws_subnet.public_subnet_b
    {% endif %}

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

    {% if environment_config.ecs_autoscale_min_instances %}
      ecs_autoscale_min_instances = "{{environment_config.ecs_autoscale_min_instances}}"
    {% endif %}

    {% if environment_config.ecs_autoscale_max_instances %}
      ecs_autoscale_max_instances = "{{environment_config.ecs_autoscale_max_instances}}"
    {% endif %}
    
  }

  output "{{service_name}}_docker_registry" {
    value = module.service-{{service_name}}.docker_registry
  }

  output "{{service_name}}_lb_dns" {
    value = ""
  }

  output "{{service_name}}_task_security_group_id" {
    value = module.service-{{service_name}}.task_security_group_id
  }

{% endif %}

