
resource "aws_s3_bucket" "zoko_bucket" {
  bucket_prefix = "zoko-${var.environment}"
  acl           = "private"
}
