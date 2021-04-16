
# == RDS ==
# Any output with prefix of 'DGVAR_' will be mapped to the
# template
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

  # to output a secret, simply output the ARN value of a parameter store
  output "DGVAR_POSTGRES_PASSWORD" {
    value = aws_ssm_parameter.database_password.arn
    sensitive = true
  }

  output "DGVAR_POSTGRES_PORT" {
    value = module.rds.database_port
  }

  # == BASTION ==
  output "BASTION_PUBLIC_IP" {
    value = aws_eip.bastion.public_ip
  }
    
{% endif %}
