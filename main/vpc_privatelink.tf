
resource "aws_security_group" "vpc_endpoint_security" {
  name_prefix = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      aws_subnet.private_subnet_a.id,
      aws_subnet.private_subnet_b.id
    ]
  }
}

# for fargate access to ssm secrets
resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.eu-west-1.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.vpc_endpoint_security.id,
  ]

  private_dns_enabled = true
}
