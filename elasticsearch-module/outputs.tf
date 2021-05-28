
output "domain" {
  value = var.domain_name
}

output "master_username" {
  value = local.es_username
}

output "master_password" {
  value = local.es_password
}

output "domain_arn" {
  value = aws_elasticsearch_domain.es.arn
}
