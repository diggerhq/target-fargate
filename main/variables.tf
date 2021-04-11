/*
 * variables.tf
 * Common variables to use in various Terraform files (*.tf)
 */

# The AWS region to use for the dev environment's infrastructure
variable "region" {
  default = "us-east-1"
}

# Tags for the infrastructure
variable "tags" {
  type = map(string)
}

# The application's name
variable "app" {
}

# The environment that is being built
variable "environment" {
}

# ecs derived variable names
variable "ecs_cluster_name" {}

# DNS 
variable "dns_hosted_zone" {
  type        = string
  description = "The Route53 zone in which to add the DNS entry"
}

variable "certificate_arn" {
  type = string
  description = "ARN of the domain certificate"
}

# Network configuration

# The VPC to use for the Fargate cluster
# variable "vpc" {
# }

# The private subnets, minimum of 2, that are a part of the VPC(s)
# variable "private_subnets" {
# }

# The public subnets, minimum of 2, that are a part of the VPC(s)
# variable "public_subnets" {
# }
