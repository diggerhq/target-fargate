{% if environment_config.needs_s3 %}
resource "aws_s3_bucket" "b" {
  bucket_prefix = "${var.app}"
  acl    = "private"
}
{% endif %}

