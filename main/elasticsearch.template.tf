  
{% if environment_config.needs_elasticsearch %}
  module "elasticsearch" {
    source = "../elasticsearch-module"

    domain_name = "${var.ecs_cluster_name}-${var.environment}"
  }

  output "DGVAR_ES_DOMAIN" {
    value = module.elasticsearch.domain
  }

  output "DGVAR_ES_MASTER_USERNAME" {
    value = module.elasticsearch.master_username
  }

  output "DGVAR_ES_MASTER_PASSWORD" {
    value = module.elasticsearch.master_password
  }

{% endif %}