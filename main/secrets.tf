
resource "random_password" "django_secret" {
  length           = 32
  special          = true
}

resource "aws_ssm_parameter" "django_secret" {
  name = "${var.app}.${var.environment}.django_secret"
  value = random_password.django_secret.result
  type = "SecureString"
}

resource "random_string" "admin_str_random" {
  length           = 6
  special          = false
}
