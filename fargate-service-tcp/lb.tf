# note that this creates the nlb, target group, and access logs
# the listeners are defined in lb-http.tf and lb-https.tf
# delete either of these if your app doesn't need them
# but you need at least one



resource "aws_lb" "main" {
  name = "${var.ecs_cluster.name}-${var.service_name}"
  load_balancer_type = "network"
  # launch lbs in public or private subnets based on "internal" variable
  internal = var.internal
  enable_cross_zone_load_balancing = "true"

  subnets = [
    var.lb_subnet_a.id,
    var.lb_subnet_b.id
  ]
  tags            = var.tags

  # enable access logs in order to get support from aws
  access_logs {
    enabled = false
    bucket  = aws_s3_bucket.lb_access_logs.bucket
  }
}

resource "aws_lb_listener" "tcp" {
  load_balancer_arn = aws_lb.main.id
  port              = var.lb_port
  protocol          = var.lb_protocol

  default_action {
    target_group_arn = aws_lb_target_group.main.id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "main" {
  name                 = "${var.ecs_cluster.name}-${var.service_name}"
  port                 = var.lb_port
  protocol             = var.health_check_protocol
  vpc_id               = var.service_vpc.id
  target_type          = "ip"
  deregistration_delay = var.deregistration_delay

  health_check {
    path                = var.health_check
    interval            = var.health_check_interval
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  stickiness {
    enabled = false
    type = "source_ip"
  }

  lifecycle {
    create_before_destroy = true
  }
    
  tags = var.tags
}

data "aws_elb_service_account" "main" {
}

# bucket for storing NLB access logs
resource "aws_s3_bucket" "lb_access_logs" {
  bucket_prefix = "${var.ecs_cluster.name}-${var.service_name}"
  tags          = var.tags
  force_destroy = true
}

resource "aws_s3_bucket_acl" "lb_access_logs_acl" {
  bucket = aws_s3_bucket.lb_access_logs.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "lb_access_logs_lifecycle_rule" {
  bucket = aws_s3_bucket.lb_access_logs.id

  rule {
    id     = "cleanup"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
    expiration {
      days = var.lb_access_logs_expiration_days
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lb_access_logs_server_side_encryption" {
  bucket = aws_s3_bucket.lb_access_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# give load balancing service access to the bucket
resource "aws_s3_bucket_policy" "lb_access_logs" {
  bucket = aws_s3_bucket.lb_access_logs.id

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.lb_access_logs.arn}",
        "${aws_s3_bucket.lb_access_logs.arn}/*"
      ],
      "Principal": {
        "AWS": [ "${data.aws_elb_service_account.main.arn}" ]
      }
    }
  ]
}
POLICY
}

# The load balancer DNS name
output "lb_dns" {
  value = aws_lb.main.dns_name
}
