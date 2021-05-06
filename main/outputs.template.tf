
# == RDS ==

{% if environment_config.no_database is sameas True %}
  output "DGVAR_POSTGRES_HOST" {
    value = "<<POSTGRES_HOST>>"
  }

  output "DGVAR_POSTGRES_DB" {
    value = "<<POSTGRES_DB>>"
  }

  output "DGVAR_POSTGRES_USER" {
    value = "<<POSTGRES_USER>>"
  }

  output "DGVAR_POSTGRES_PASSWORD" {
    value = "<<POSTGRES_PASSWORD>>"
    sensitive = true
  }

  output "DGVAR_POSTGRES_PORT" {
    value = "<<POSTGRES_PORT>>"
  }
{% else %}
  output "DGVAR_POSTGRES_HOST" {
    value = local.database_address
  }

  output "DGVAR_POSTGRES_DB" {
    value = local.database_name
  }

  output "DGVAR_POSTGRES_USER" {
    value = local.database_username
  }

  output "DGVAR_POSTGRES_PASSWORD" {
    value = aws_ssm_parameter.database_password.arn
    sensitive = true
  }

  output "DGVAR_POSTGRES_PORT" {
    value = module.zoko_rds.database_port
  }

  # == BASTION ==
  output "BASTION_PUBLIC_IP" {
    value = aws_eip.bastion.public_ip
  }
    
{% endif %}

# == BUCKETS ==

output "DGVAR_S3_BUCKET" {
  value = aws_s3_bucket.zoko_bucket.id
}

# == KAFKA ==

# == IAM USER ==

output "DGVAR_AWS_IAM_USER_NAME" {
  value = aws_iam_user.iam_user.name  
}

output "DGVAR_AWS_ACCESS_KEY_ID" {
  value = aws_ssm_parameter.iam_user_access_key.arn
  sensitive = true  
}

output "DGVAR_AWS_SECRET_ACCESS_KEY" {
  value = aws_ssm_parameter.iam_user_secret.arn
  sensitive = true  
}
# == OTHER == 
