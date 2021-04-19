

# == logging == 

output "DGVAR_AWS_LOG_GROUP" {
  value = "${var.app}-${var.environment}-paas"
}

output "DGVAR_AWS_LOG_STREAM" {
  value = "${var.app}-${var.environment}-backend"
}

output "DGVAR_AWS_LOGGER_NAME" {
  value = "watchtower-logger"
}
  
output "DGVAR_CLOUDWATCH_AGENT_ACCESS_KEY_ID" {
  value = aws_ssm_parameter.iam_user_access_key.arn  
}

output "DGVAR_CLOUDWATCH_AGENT_SECRET_ACCESS_KEY" {
  value = aws_ssm_parameter.iam_user_secret.arn
}

output "DGVAR_CLOUDWATCH_AGENT_REGION" {
  value = var.region
}

# == Redis == 

output "DGVAR_REDIS_URL" {
  value = local.redis_url
}

# == RDS ==

{% if environment_config.no_database is sameas True %}

  output "DGVAR_DATABASE_URL" {
    value = "<<DATABASE_URL>>"
    sensitive = true
  }

{% else %}

  output "DGVAR_DATABASE_URL" {
    value = aws_ssm_parameter.database_url.arn
    sensitive = true
  }

  # == BASTION ==
  output "BASTION_PUBLIC_IP" {
    value = aws_eip.bastion.public_ip
  }
    
{% endif %}

# == BUCKETS ==

output "DGVAR_DIGGER_MEDIA_BUCKET_NAME" {
  value = aws_s3_bucket.digger_media.id

output "DGVAR_TFORM_BACKEND_BUCKET_NAME" {
  value = aws_s3_bucket.digger_terraform_states.id
}

output "DGVAR_TFORM_BACKEND_KEY_SUFFIX" {
  value = "project"
}

# CODEBUILD ==

output "DGVAR_CODEBUILD_RUNNER_PROJECT_NAME" {
  value = "<<>>"
}

output "DGVAR_CODEBUILD_RUNNER_BUILDSPEC_ARN" {
  value = "<<>>"
}

output "DGVAR_CODEBUILD_RUNNER_REGION" {
  value = "<<>>"
}

# == USERS ==

output "DGVAR_MANAGED_AWS_ACCESS_KEY_ID" {
  value = aws_ssm_parameter.iam_user_access_key.arn
}

output "DGVAR_MANAGED_AWS_SECRET_ACCESS_KEY" {
  value = aws_ssm_parameter.iam_user_secret.arn
}


# == MISC ==

output "DGVAR_PORT" {
  value = "8000"
}

output "DGVAR_ENVIRONMENT_NAME" {
  value = var.environment
}

output "DGVAR_USING_DOCKER_COMPOSE" {
  value = "false"
}

output "DGVAR_DJANGO_SECRET_KEY" {
  value = aws_ssm_parameter.django_secret.arn
  sensitive = true
}

output "DGVAR_DJANGO_SETTINGS_MODULE" {
  value = "config.settings.production"
}
output "DGVAR_DJANGO_CONFIGURATION" {
  value = "Production"
}

output "DGVAR_DJANGO_ALLOWED_HOSTS" {
  value = "*"
}

output "DGVAR_DJANGO_CORS_ORIGIN_WHITELIST" {
  value = "https://app.digger.dev,"
}

output "DGVAR_DJANGO_ADMIN_URL" {
  value = concat("admin", random_string.admin_str_random)
}

output "DGVAR_GITHUB_KEY" {
  value = "<<GH_KEY>>"
}

output "DGVAR_GITHUB_SECRET" {
  value = "<<GH_SECRET>>"
}
