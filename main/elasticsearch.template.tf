
{% if environment_config.needs_elasticsearch %}

  locals {
    account_id = data.aws_caller_identity.current.account_id
    es_domain_name = "${var.ecs_cluster_name}-${var.environment}"
    event_stream = aws_cloudwatch_event_rule.ecs_event_stream.name
  }

  module "elasticsearch" {
    source = "../elasticsearch-module"
    domain_name = local.es_domain_name
  }

  data "aws_caller_identity" "current" {}


  resource "aws_iam_role" "es_lambda_role" {
    name_prefix = "${var.app}-${var.environment}-es-lambda-role"

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {"Service": "lambda.amazonaws.com"},
            "Action": "sts:AssumeRole"
        }
    ]
}
    EOF
  }

  data "aws_iam_policy_document" "cloudwatch" {
      version = "2012-10-17"
      statement {
        sid = "${var.app}${var.environment}EsCloudwatchPolicyDocument"
        actions = [
          "es:*"
        ]
        effect = "Allow"
        resources = [
          "arn:aws:es:${var.region}:${local.account_id}:domain/${local.es_domain_name}/*"            
        ]
    }
  }

  resource "aws_iam_policy" "cloudwatch" {
      name   = "${var.app}-${var.environment}-es-cloudwatch-policy"
      policy = data.aws_iam_policy_document.cloudwatch.json
  }

  resource "aws_iam_role_policy_attachment" "gateway_connections" {
      role       = aws_iam_role.es_lambda_role.name
      policy_arn = aws_iam_policy.cloudwatch.arn
  }

  # map to cloudwatch stream
  resource "aws_cloudwatch_log_subscription_filter" "test_lambdafunction_logfilter" {
    name            = "${var.ecs_cluster_name}-${var.environment}-elasticsearch-stream"
    role_arn        = aws_iam_role.es_lambda_role.arn
    log_group_name  = local.event_stream
    filter_pattern  = "{ $.path != \"/api/v1/hello\" }"
    destination_arn = module.elasticsearch.domain_arn
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