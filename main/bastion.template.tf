resource "aws_security_group" "bastion_sg" {
  name_prefix   = "bastion-security-group"
  vpc_id = local.vpc.id

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

{% if environment_config.needs_bastion is sameas True %}

  resource "aws_key_pair" "bastion_key" {
    key_name_prefix = "${var.app}-${var.environment}" 
    public_key = "{{environment_config.bastion_public_key}}"
  }

  resource "aws_eip" "bastion" {
    instance = aws_instance.bastion.id
    vpc      = true
  }

  resource "aws_instance" "bastion" {
    subnet_id                   = aws_subnet.public_subnet_a.id
    ami                         = "{{environment_config.bastion_ami}}"
    key_name                    = aws_key_pair.bastion_key.key_name
    instance_type               = "t2.micro"
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.bastion_sg.id]

    tags = {
      Name = "${var.app}-${var.environment} Bastion"
    }
  }

  output "bastion_public_ip" {
    value = aws_eip.bastion.public_ip
  }

{% endif %}


output "bastion_security_group_id" {
  value = aws_security_group.bastion_sg.id  
}

