
variable "ecs_cluster" {}

variable "service_name" {}

# The tag mutability setting for the repository (defaults to IMMUTABLE)
variable "image_tag_mutability" {
  type        = string
  default     = "MUTABLE"
  description = "The tag mutability setting for the repository (defaults to IMMUTABLE)"
}

variable "service_vpc" {}

variable "service_security_groups" {
  default = []
}

variable "region" {}

variable "tags" {}

# === Load Balancer ===

# The loadbalancer subnets
variable "lb_subnet_a" {}
variable "lb_subnet_b" {}

# Whether the application is available on the public internet,
# also will determine which subnets will be used (public or private)
variable "internal" {
  default = true
}


# === Container ===



# The port the container will listen on, used for load balancer health check
# Best practice is that this value is higher than 1024 so the container processes
# isn't running at root.


# How many containers to run
variable "replicas" {
  default = "1"
}

# The name of the container to run
variable "container_name" {
}

variable "launch_type" {
}

# The minimum number of containers that should be running.
# Must be at least 1.
# used by both autoscale-perf.tf and autoscale.time.tf
# For production, consider using at least "2".
variable "ecs_autoscale_min_instances" {
  default = "1"
}

# The maximum number of containers that should be running.
# used by both autoscale-perf.tf and autoscale.time.tf
variable "ecs_autoscale_max_instances" {
  default = "8"
}

# The default docker image to deploy with the infrastructure.
# Note that you can use the fargate CLI for application concerns
# like deploying actual application images and environment variables
# on top of the infrastructure provisioned by this template
# https://github.com/turnerlabs/fargate
# note that the source for the turner default backend image is here:
# https://github.com/turnerlabs/turner-defaultbackend
variable "default_backend_image" {
  default = "quay.io/turner/turner-defaultbackend:0.2.0"
}

variable "task_cpu" {
  default = "256"
}

variable "task_memory" {
  default = "512"
}

# == Cloudwatch ==


variable "logs_retention_in_days" {
  type        = number
  default     = 90
  description = "Specifies the number of days you want to retain log events"
}
