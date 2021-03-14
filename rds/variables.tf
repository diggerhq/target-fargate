
variable "vpc_id" {}

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
