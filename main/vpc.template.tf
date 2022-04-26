
variable "instanceTenancy" {
  default = "default"
}

variable "dnsSupport" {
  default = true
}

variable "dnsHostNames" {
  default = true
}

variable "vpcCIDRblock" {
  default = "10.0.0.0/16"
}

variable "publicSubnetaCIDRblock" {
  default = "10.0.1.0/24"
}

variable "publicSubnetbCIDRblock" {
  default = "10.0.2.0/24"
}

variable "publicSubnetcCIDRblock" {
  default = "10.0.5.0/24"
}

variable "publicSubnetdCIDRblock" {
  default = "10.0.6.0/24"
}

variable "privateSubnetaCIDRblock" {
  default = "10.0.3.0/24"
}

variable "privateSubnetbCIDRblock" {
  default = "10.0.4.0/24"
}

variable "destinationCIDRblock" {
  default = "0.0.0.0/0"
}

variable "ingressCIDRblock" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "egressCIDRblock" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "mapPublicIP" {
  default = false
}

# this config allows creating subbnets in an existing VPC
data "aws_vpc" "vpc" {
  id = "{{environment_config.vpc_id}}"
}

locals {
  vpc = data.aws_vpc.vpc
}

# output the vpc ids
output "vpc_id" {
  value = data.aws_vpc.vpc.id
}

output "security_group_ids" {
  value = [aws_security_group.ecs_service_sg.id]
}