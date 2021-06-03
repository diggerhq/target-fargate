

{% if environment_config.needs_database is sameas True %}
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

