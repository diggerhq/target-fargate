/*
 * variables.tf
 * Common variables to use in various Terraform files (*.tf)
 */

# The AWS region to use for the dev environment's infrastructure
variable "region" {
  default = "us-east-1"
}

# The application's name
variable "app" {
}

# The environment that is being built
variable "environment" {
}

# ecs derived variable names
variable "ecs_cluster_name" {}

# RDS

variable "rds_instance_class" {
  default = "db.t3.micro"
}

# redis

variable "rds_node_type" {
  default = "cache.m4.large"
}
