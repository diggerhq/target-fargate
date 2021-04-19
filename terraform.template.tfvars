iam_user = "{{iam_user}}-{{environment}}"
aws_key = "{{aws_key}}"
aws_secret = "{{aws_secret}}"

app = "{{app_name}}"
# service_name = "{{service_name}}"
environment = "{{environment}}"

# ecs derived name (doing checks for backward compatability)
ecs_cluster_name = "{{app_name}}-{{environment}}"

region = "{{region}}"
availabilityZone_a = "{{region}}a"
availabilityZone_b = "{{region}}b"

{% if environment_config.rds_instance_class %}
rds_instance_class= "{{environment_config.rds_instance_class}}"
{% endif %}

{% if environment_config.redis_node_type %}
redis_node_type= "{{environment_config.redis_node_type}}"
{% endif %}

