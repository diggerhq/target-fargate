
resource "aws_s3_bucket" "csv_bucket" {
  bucket_prefix = "csv_bucket"
  acl           = "private"
}

resource "aws_s3_bucket" "s3_download_bucket" {
  bucket_prefix = "s3_download_bucket"
  acl           = "private"
}
