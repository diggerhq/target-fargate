

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