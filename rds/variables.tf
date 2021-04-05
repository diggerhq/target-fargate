
variable "allocated_storage" {
  type        = number
  default     = 10
  description = "The default storage for the RDS instance"
} 

variable "engine" {
  default = "postgres"
}

variable "engine_version" {
  default = "12" 
}

variable "instance_class" {
  default = "db.m5.large"
}

variable "database_name" {
  default = "digger"
}

variable "database_username" {
  default = "digger" 
}

variable "publicly_accessible" {
  default = false
}

variable "vpc_security_group_ids" {
  default = []
}

variable "db_subnet_group_name" {
  default = null
  description = "The subnet group associated with RDS instance"
}
