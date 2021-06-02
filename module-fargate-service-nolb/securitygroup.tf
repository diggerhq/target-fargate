
resource "aws_security_group" "nsg_task" {
  name        = "${var.ecs_cluster.name}-${var.service_name}-task"
  description = "Limit connections from internal resources while allowing ${var.ecs_cluster.name}-task to connect to all external resources"
  vpc_id      = var.service_vpc.id

  tags = var.tags
}

resource "aws_security_group_rule" "nsg_task_ingress_rule" {
  description = "Allows task to establish connections to all resources"
  type        = "ingress"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.nsg_task.id
}

output "task_security_group_id" {
  value = aws_security_group.nsg_task.id
}

resource "aws_security_group_rule" "nsg_task_egress_rule" {
  description = "Allows task to establish connections to all resources"
  type        = "egress"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.nsg_task.id
}
