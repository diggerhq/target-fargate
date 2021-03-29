
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
    value = module.qc_rds.database_port
  }
{% endif %}

# == BUCKETS ==

output "DGVAR_S3_DOWNLOAD_BUCKET" {
  value = aws_s3_bucket.csv_bucket.id
}

output "DGVAR_CSV_BUCKET" {
  value = aws_s3_bucket.s3_download_bucket.id
}

output "DGVAR_MODEL_BUCKET" {
  value = "quantcopy.models"
}

# == ELASTICSEARCH ==

output "DGVAR_ES_URI" {
  value = "<<ES_URI>>"
}

output "DGVAR_CONTENT_INDEX" {
  value = "<<CONTENT_INDEX>>"
}

output "DGVAR_INSIGHT_INDEX" {
  value = "<<INSIGHT_INDEX>>"
}

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

# == AUTH0 ==

output "DGVAR_MARIO_AUTH0_AUDIENCE" {
  value = "mario-backend"
}

output "DGVAR_MARIO_AUTH0_DOMAIN" {
  value = "quantcopy.eu.auth0.com"
}

# == OTHER == 

output "DGVAR_MARIO_DOWNSTREAM" {
  value = "<<MARIO_DOWNSTREAM>>"
}

output "DGVAR_MARIO_ENV" {
  value = "production"
}

output "DGVAR_SPACY_MODEL" {
  value = "en_core_web_md"
}

output "DGVAR_PYTHONPATH" {
  value = "."
}

output "DGVAR_DATA_PATH" {
  value = ".data"
}
