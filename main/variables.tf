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
  default = {
    "test" = "test"
  }
}

# The application's name
variable "app" {
  default = "zoko"
}

# The environment that is being built
variable "environment" {
  default = "dev"
}

# ecs derived variable names
variable "ecs_cluster_name" {
  default = "default"
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
