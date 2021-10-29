
locals {
  redis_port = 6379
  redis_url = "${aws_elasticache_cluster.dg_redis.cache_nodes[0].address}:${local.redis_port}"
}

resource "aws_security_group" "dgredis" {
  name_prefix = "${var.app}-${var.environment}-dgdb-sg"
  vpc_id = aws_vpc.vpc.id
  description = "RDS postgres servers (terraform-managed)"

  # Only postgres in
  ingress {
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    security_groups = [aws_security_group.ecs_service_sg.id, aws_security_group.bastion_sg.id]
  }

  # Allow all outbound traffic.
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_cluster" "dg_redis" {
  cluster_id           = "${var.app}-${var.environment}-dg-redis"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "6.0.5"
  port                 = local.redis_port
  security_group_ids   = [aws_security_group.dgredis.id]
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
}

