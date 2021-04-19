
resource "aws_s3_bucket" "digger_media" {
  bucket_prefix = "digger-media-assets"
  acl           = "private"
}

resource "aws_s3_bucket" "digger_terraform_states" {
  bucket_prefix = "digger-terraform-states"
  acl           = "private"
}
