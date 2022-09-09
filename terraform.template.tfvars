aws_key = "{{aws_key}}"
aws_secret = "{{aws_secret}}"
digger_aws_key = "{{digger_aws_key}}"
digger_aws_secret = "{{digger_aws_secret}}"
app = "{{app_name}}"
environment = "{{environment}}"

# ecs derived name (doing checks for backward compatability)
ecs_cluster_name = "{{app_name}}-{{environment}}"

region = "{{region}}"

alarms_sns_topic_arn = "{{alarms_sns_topic_arn}}"
monitoring_enabled = {{monitoring_enabled | lower}}

# aws_profile = "default"
# container_port = "{{container_port}}"
# replicas = "1"
# health_check = "{{health_check}}"
tags = {
  application   = "{{app_name}}"
  environment   = "{{environment}}"
  team          = "{{app_name}}-team"
  customer      = "{{app_name}}-customer"
  contact-email = "me@domain.com"
}

{% if environment_config.vpcCIDRblock %}
vpcCIDRblock = "{{environment_config.vpcCIDRblock}}"
publicSubnetaCIDRblock = "{{environment_config.publicSubnetaCIDRblock}}"
publicSubnetbCIDRblock = "{{environment_config.publicSubnetbCIDRblock}}"
privateSubnetaCIDRblock = "{{environment_config.privateSubnetaCIDRblock}}"
privateSubnetbCIDRblock = "{{environment_config.privateSubnetbCIDRblock}}"
{% endif %}
# internal = false

{% if environment_config.lb_enable_https_redirect is defined and environment_config.lb_enable_https_redirect %}
lb_enable_https_redirect = true
{% endif %}
