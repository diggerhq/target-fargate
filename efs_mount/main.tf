
resource "aws_efs_file_system" "fs" {
  creation_token = var.service_name
  encrypted = true

  tags = {
    Name = var.service_name
  }
}

resource "aws_efs_mount_target" "fs_a" {
  file_system_id  = aws_efs_file_system.fs.id
  subnet_id       = var.subnet_a_id
  security_groups = []
}

resource "aws_efs_mount_target" "fs_b" {
  file_system_id  = aws_efs_file_system.fs.id
  subnet_id       = var.subnet_b_id
  security_groups = []
}

# resource "aws_efs_backup_policy" "fs" {
#   file_system_id = aws_efs_file_system.fs.id

#   backup_policy {
#     status = "ENABLED"
#   }
# }

