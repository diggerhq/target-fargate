variable "ecs_cluster_name" {}

variable "ecs_service_name" {}

variable "alarms_sns_topic_arn" {}

variable "target_3xx_count_threshold" {
  default = 5
}

variable "target_4xx_count_threshold" {
  default = 5
}

variable "target_5xx_count_threshold" {
  default = 5
}

variable "elb_5xx_count_threshold" {
  default = 5
}

variable "target_response_time_threshold" {
  default = 1
}

variable "target_group_arn_suffix" {}

variable "alb_arn_suffix" {}

variable "tags" {}

