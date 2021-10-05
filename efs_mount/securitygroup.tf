
resource "aws_security_group" "efs_sg" {
  name_prefix = "${service_name}-efs"
  description = "EFS SG"
  vpc_id      = var.service_vpc.id
}

# Rules for the TASK (Targets the LB SG)
resource "aws_security_group_rule" "nsg_task_ingress_rule" {
  description              = ""
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = var.ecs_securitygroup_id

  security_group_id = aws_security_group.efs_sg.id
}

resource "aws_security_group_rule" "nsg_task_egress_rule" {
  description = ""
  type        = "egress"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.efs_sg.id
}
