
resource "aws_s3_bucket" "csv_bucket" {
  bucket_prefix = "csv-bucket"
  acl           = "private"
}

resource "aws_s3_bucket" "s3_download_bucket" {
  bucket_prefix = "s3-download-bucket"
  acl           = "private"
}
