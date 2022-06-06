
variable "allocated_storage" {
  type        = number
  default     = 100
  description = "The default storage for the RDS instance"
} 


variable "iops" {
  type        = number
  default     = 1000
  description = "The default storage for the RDS instance"
} 

variable "identifier_prefix" {}

variable "engine" {
  default = "postgres"
}

variable "engine_version" {
  default = "12" 
}

variable "instance_class" {
  default = "db.t3.micro"
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

variable "snapshot_identifier" {
  default = ""
}

variable "db_subnet_group_name" {
  default = null
  description = "The subnet group associated with RDS instance"
}