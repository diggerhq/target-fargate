variable "ecs_cluster_name" {}

variable "ecs_service_name" {}

variable "alarms_sns_topic_arn" {}

variable "tags" {}

variable "cpu_utilization_high_threshold" {
  default = 80
}

variable "memory_utilization_high_threshold" {
  default = 100
}

variable "cpu_utilization_high_evaluation_periods" {
  default = 1
}

variable "cpu_utilization_high_period" {
  default = 60
}

variable "memory_utilization_high_evaluation_periods" {
  default = 1
}

variable "memory_utilization_high_period" {
  default = 60
}
