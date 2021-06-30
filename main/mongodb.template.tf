
{% if environment_config.needs_mongodb %}

locals {
  mongodb_username = "digger"
  mongodb_password = random_password.rabbitmq_password.result
}

resource "aws_docdb_subnet_group" "docdb" {
  name       = "${var.app}-${var.environment}-docdb-subnetgroup"
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id ]

  tags = {
    Name = "${var.app} ${var.environment} docdb subnetgroup"
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
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = 2
  identifier         = "docdb-cluster-demo-${count.index}"
  cluster_identifier = aws_docdb_cluster.default.id
  instance_class     = "db.t3.medium"
}


{% endif %}