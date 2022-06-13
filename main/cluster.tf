

resource "aws_ecs_cluster" "app" {
  name = var.ecs_cluster_name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = var.tags
}

resource "aws_security_group" "ecs_service_sg" {
  name_prefix = "${var.ecs_cluster_name}-${var.environment}"
  description = "Security group shared by all ECS services"
  vpc_id      = local.vpc.id
}


resource "aws_security_group_rule" "ecs_service_sg_egress_rule" {
  description = "Allows task to establish connections to all resources"
  type        = "egress"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.ecs_service_sg.id
}