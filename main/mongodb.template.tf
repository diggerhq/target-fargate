
{% if environment_config.needs_mongodb %}

locals {
  mongodb_username = "digger"
  mongodb_password = random_password.mongodb.result
}

resource "aws_docdb_subnet_group" "docdb" {
  name       = "${var.app}-${var.environment}-docdb-subnetgroup"
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id ]

  tags = {
    Name = "${var.app} ${var.environment} docdb subnetgroup"
  }
}

# Only printable ASCII characters besides '/', '@', '"', ' ' may be used.
resource "random_password" "mongodb" {
  length           = 21
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
  special          = true
  lower            = true
  upper            = true
  number           = true
  override_special = "!?*."
}

resource "aws_security_group" "mongodb" {
  name_prefix = "${var.app}-${var.environment}-mongodb-sg"
  vpc_id = local.vpc.id
  description = "mongodb security group"

  # Only postgres in
  ingress {
    from_port = 27017
    to_port = 27017
    protocol = "tcp"
    security_groups = [aws_security_group.ecs_service_sg.id, aws_security_group.bastion_sg.id]
  }

  # Only postgres in
  ingress {
    from_port = 443
    to_port = 443
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

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier        = "${var.app}-${var.environment}-docdb"
  engine                    = "docdb"
  db_subnet_group_name      = aws_docdb_subnet_group.docdb.name
  master_username           = local.mongodb_username
  master_password           = local.mongodb_password
  backup_retention_period   = 5
  preferred_backup_window   = "07:00-09:00"
  final_snapshot_identifier = "${var.app}-${var.environment}-final-snapshot"
  skip_final_snapshot       = false
  vpc_security_group_ids    = [aws_security_group.mongodb.id]
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = 2
  identifier         = "${var.app}-${var.environment}-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = "db.t3.medium"
}


resource "aws_ssm_parameter" "mongodb_username" {
  name = "${var.app}.${var.environment}.mongodb.username"
  value = local.mongodb_username
  type = "SecureString"
}

resource "aws_ssm_parameter" "mongodb_password" {
  name = "${var.app}.${var.environment}.mongodb.password"
  value = local.mongodb_password
  type = "SecureString"
}

{% endif %}