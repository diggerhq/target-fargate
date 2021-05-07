
resource "aws_instance" "cassandra" {
  count = 3
  ami           = "ami-0960d43e248a0602c"
  instance_type = "m5.large"
  subnet_id = aws_subnet.private_subnet_a.id

  tags = {
    Name = "${var.project}-${var.environment}-cassandra${count.index}"
  }

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 120
  }
}
