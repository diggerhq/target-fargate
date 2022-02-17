
variable "service_name" {
  type = string
  description = "Name of the service"
}

variable "vpc_id" {
  type = string
  description = "VPC ID"
}

variable "subnet_a_id" {
  type = string
  description = "ID of first subnet"
}

variable "subnet_b_id" {
  type = string
  description = "ID of second subnet"
}

variable "ecs_securitygroup_id" {
}