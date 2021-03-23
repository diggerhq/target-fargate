
resource "aws_iam_user" "iam_user" {
  name = "${var.app}-${var.environment}-iam-user"
}

resource "aws_iam_access_key" "iam_user" {
  user = aws_iam_user.iam_user.name
}

# access to s3 resources for this user
resource "aws_iam_user_policy" "s3_access_models_policy" {
  name = "test"
  user = aws_iam_user.iam_user.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::quantcopy.models/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                aws_s3_bucket.csv_bucket.arn,
                aws_s3_bucket.s3_download_bucket.arn
            ]
        }
    ]
}
EOF
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
