iam_user = "{{iam_user}}-{{environment}}"
aws_key = "{{aws_key}}"
aws_secret = "{{aws_secret}}"

app = "{{app_name}}"
# service_name = "{{service_name}}"
environment = "{{environment}}"

# ecs derived name (doing checks for backward compatability)
ecs_cluster_name = "{{app_name}}-{{environment}}"

region = "{{region}}"

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

# internal = false

# launch_type = "{{launch_type}}"

# default_backend_image = "{{backend_image}}"
