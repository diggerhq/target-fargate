{% if environment_config.needs_database is sameas True %}

  resource "aws_key_pair" "bastion_key" {
    key_name_prefix = "${var.app}-${var.environment}" 
    public_key = "{{environment_config.bastion_public_key}}"
  }

  resource "aws_security_group" "bastion_sg" {
    name   = "bastion-security-group"
    vpc_id = aws_vpc.vpc.id

    ingress {
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      protocol    = -1
      from_port   = 0 
      to_port     = 0 
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  resource "aws_eip" "bastion" {
    instance = aws_instance.bastion.id
    vpc      = true
  }

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

  resource "aws_instance" "bastion" {
    subnet_id                   = data.aws_ami.ubuntu.id
    ami                         = "ami-01720b5f421cf0179"
    key_name                    = aws_key_pair.bastion_key.key_name
    instance_type               = "t2.micro"
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  }

{% endif %}