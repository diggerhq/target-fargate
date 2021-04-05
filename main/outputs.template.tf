
# == RDS ==

{% if environment_config.no_database is sameas True %}
  output "DGVAR_LEXIKO_POSTGRESQL_HOST" {
    value = "<<POSTGRES_HOST>>"
  }

  output "DGVAR_LEXIKO_POSTGRESQL_DB" {
    value = "<<POSTGRES_DB>>"
  }

  output "DGVAR_LEXIKO_POSTGRESQL_USER" {
    value = "<<POSTGRES_USER>>"
  }

  output "DGVAR_LEXIKO_POSTGRESQL_PASSWORD" {
    value = "<<POSTGRES_PASSWORD>>"
    sensitive = true
  }

  output "DGVAR_LEXIKO_POSTGRESQL_PORT" {
    value = "<<POSTGRES_PORT>>"
  }
{% else %}
  output "DGVAR_LEXIKO_POSTGRESQL_HOST" {
    value = local.database_address
  }

  output "DGVAR_LEXIKO_POSTGRESQL_DB" {
    value = local.database_name
  }

  output "DGVAR_LEXIKO_POSTGRESQL_USER" {
    value = local.database_username
  }

  output "DGVAR_LEXIKO_POSTGRESQL_PASSWORD" {
    value = aws_ssm_parameter.database_password.arn
    sensitive = true
  }

  output "DGVAR_LEXIKO_POSTGRESQL_PORT" {
    value = module.lex_rds.database_port
  }

  # == BASTION ==
  output "BASTION_PUBLIC_IP" {
    value = aws_eip.bastion.public_ip
  }

{% endif %}
