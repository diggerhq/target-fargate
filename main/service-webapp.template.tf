
{% if service_type == "webapp" %}

locals {
  {{service_name}}_website_domain = "{{app_name}}-{{environment}}-{{service_name}}.{{environment_config.hostname}}"
}

## S3
# bucket for logs
resource "aws_s3_bucket" "{{service_name}}_website_logs" {
  bucket_prefix = "{{app_name}}-{{environment}}-{{service_name}}-logs"
  acl    = "log-delivery-write"

  # allow terraform to destroy non-empty bucket
  force_destroy = true

  lifecycle {
    ignore_changes = [tags["Changed"]]
  }
}


# Creates bucket to store the static website
resource "aws_s3_bucket" "{{service_name}}_website_root" {
  bucket_prefix = "{{app_name}}-{{environment}}-{{service_name}}-root"
  acl    = "public-read"

  # allow terraform to destroy non-empty bucket
  force_destroy = true

  logging {
    target_bucket = aws_s3_bucket.website_logs.bucket
    target_prefix = "${local.{{service_name}}_website_domain}/"
  }

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  lifecycle {
    ignore_changes = [tags["Changed"]]
  }
}

## CloudFront
# Creates the CloudFront distribution to serve the static website
resource "aws_cloudfront_distribution" "{{service_name}}_website_cdn_root" {
  enabled     = true
  price_class = "PriceClass_All"
  # Select the correct PriceClass depending on who the CDN is supposed to serve (https://docs.aws.amazon.com/AmazonCloudFront/ladev/DeveloperGuide/PriceClass.html)
  aliases = [local.{{service_name}}_website_domain]

  origin {
    origin_id   = "origin-bucket-${aws_s3_bucket.{{service_name}}_website_root.id}"
    domain_name = aws_s3_bucket.website_root.website_endpoint

    custom_origin_config {
      origin_protocol_policy = "http-only"
      # The protocol policy that you want CloudFront to use when fetching objects from the origin server (a.k.a S3 in our situation). HTTP Only is the default setting when the origin is an Amazon S3 static website hosting endpoint, because Amazon S3 doesn’t support HTTPS connections for static website hosting endpoints.
      http_port            = 80
      https_port           = 443
      origin_ssl_protocols = ["TLSv1.2", "TLSv1.1", "TLSv1"]
    }
  }

  default_root_object = "index.html"

  logging_config {
    bucket = aws_s3_bucket.website_logs.bucket_domain_name
    prefix = "${local.{{service_name}}_website_domain}/"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "origin-bucket-${aws_s3_bucket.{{service_name}}_website_root.id}"
    min_ttl          = "0"
    default_ttl      = "300"
    max_ttl          = "1200"

    viewer_protocol_policy = "redirect-to-https" # Redirects any HTTP request to HTTPS
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "{{}}"
    ssl_support_method  = "sni-only"
  }

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_page_path    = "/404.html"
    response_code         = 404
  }


  lifecycle {
    ignore_changes = [
      tags["Changed"],
      viewer_certificate,
    ]
  }
}

# Creates the DNS record to point on the main CloudFront distribution ID
resource "aws_route53_record" "{{service_name}}_website_cdn_root_record" {
  zone_id = "{{environment_config.dns_zone_id}}"
  name    = local.{{service_name}}_website_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.{{service_name}}_website_cdn_root.domain_name
    zone_id                = aws_cloudfront_distribution.{{service_name}}_website_cdn_root.hosted_zone_id
    evaluate_target_health = false
  }
}


# Creates policy to allow public access to the S3 bucket
resource "aws_s3_bucket_policy" "{{service_name}}_update_website_root_bucket_policy" {
  bucket = aws_s3_bucket.{{service_name}}_website_root.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "PolicyForWebsiteEndpointsPublicContent",
  "Statement": [
    {
      "Sid": "PublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "{{service_name}}_Resource": [
        "${aws_s3_bucket.{{service_name}}_website_root.arn}/*",
        "${aws_s3_bucket.{{service_name}}_website_root.arn}"
      ]
    }
  ]
}
POLICY
}


{% endif %}