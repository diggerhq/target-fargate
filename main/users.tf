
resource "aws_iam_user" "iam_user" {
  name = "${var.app}-${var.environment}-iam-user"
}

resource "aws_iam_access_key" "iam_user" {
  user = aws_iam_user.iam_user.name
}

# access to s3 resources for this user
resource "aws_iam_user_policy" "s3_access_policy" {
  name = "s3_access_policy"
  user = aws_iam_user.iam_user.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "s3:GetObject",
              "s3:PutObject"
            ],
            "Resource": [
                "${aws_s3_bucket.digger_media.arn}",
                "${aws_s3_bucket.digger_media.arn}/*",
                "${aws_s3_bucket.digger_terraform_states.arn}",
                "${aws_s3_bucket.digger_terraform_states.arn}/*"
            ]
        }
    ]
}
EOF
}

# cloudwatch logging access
resource "aws_iam_user_policy_attachment" "cloudwatch_logs_access" {
  user       =  aws_iam_user.iam_user.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_ssm_parameter" "iam_user_access_key" {
  name = "${var.app}.${var.environment}.iam_user.access_key"
  value = aws_iam_access_key.iam_user.id
  type = "SecureString"
}

resource "aws_ssm_parameter" "iam_user_secret" {
  name = "${var.app}.${var.environment}.iam_user.secret"
  value = aws_iam_access_key.iam_user.secret
  type = "SecureString"
}
