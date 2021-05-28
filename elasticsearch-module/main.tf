

locals {
  es_username = "digger"
  es_password = random_password.es_password
}

resource "random_password" "es_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_elasticsearch_domain" "es" {
  domain_name           = var.domain_name
  elasticsearch_version = "7.1"

  cluster_config {
    instance_count           = var.instance_count
    instance_type            = var.instance_type
    dedicated_master_enabled = var.dedicated_master_enabled
    dedicated_master_count   = var.dedicated_master_count
    dedicated_master_type    = var.dedicated_master_type
    zone_awareness_enabled   = var.zone_awareness_enabled
  }

  ebs_options {
    ebs_enabled = var.ebs_enabled
    volume_size = var.ebs_volume_size
  }

  encrypt_at_rest {
    enabled = var.encrypt_at_rest_enabled
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  node_to_node_encryption {
    enabled = true
  }

  advanced_security_options {
    enabled = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name = "digger"
      master_user_password = random_password.es_password.result
    }
  }


  # access_policies = data.aws_iam_policy_document.this.json

  # log_publishing_options {
  #   log_type                 = "SEARCH_SLOW_LOGS"
  #   cloudwatch_log_group_arn = aws_cloudwatch_log_group.es_slow_logs.arn
  #   enabled                  = "true"
  # }

  # log_publishing_options {
  #   log_type                 = "INDEX_SLOW_LOGS"
  #   cloudwatch_log_group_arn = aws_cloudwatch_log_group.es_index_logs.arn
  #   enabled                  = "true"
  # }

  # log_publishing_options {
  #   log_type                 = "ES_APPLICATION_LOGS"
  #   cloudwatch_log_group_arn = aws_cloudwatch_log_group.es_app_logs.arn
  #   enabled                  = "true"
  # }

  # dynamic "cognito_options" {
  #   for_each = var.kibana_access == true ? [{}] : []
  #   content {
  #     enabled          = true
  #     user_pool_id     = aws_cognito_user_pool.kibana_user_pool[0].id
  #     identity_pool_id = aws_cognito_identity_pool.kibana_identity_pool[0].id
  #     role_arn         = aws_iam_role.kibana_cognito_role[0].arn
  #   }
  # }

  tags = {
    Domain = var.domain_name
  }

  # depends_on = [
  #   aws_iam_role_policy_attachment.kibana_cognito_role_policy
  # ]
}



