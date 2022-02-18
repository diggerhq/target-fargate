locals {
  cpu_utilization_high_threshold             = 80
  cpu_utilization_low_threshold              = 0
  memory_utilization_high_threshold          = 100
  memory_utilization_low_threshold           = 0
  cpu_utilization_high_evaluation_periods    = 1
  cpu_utilization_high_period                = 60
  cpu_utilization_low_evaluation_periods     = 1
  cpu_utilization_low_period                 = 60
  memory_utilization_high_evaluation_periods = 1
  memory_utilization_high_period             = 60
  memory_utilization_low_evaluation_periods  = 1
  memory_utilization_low_period              = 60


  dimensions_map = {
    "service" = {
      "ClusterName" = var.ecs_cluster_name
      "ServiceName" = var.ecs_service_name
    }
    "cluster" = {
      "ClusterName" = var.ecs_cluster_name
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  alarm_name          = "${var.ecs_service_name}_cpu_utilization_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = local.cpu_utilization_high_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = local.cpu_utilization_high_period
  statistic           = "Average"
  threshold           = local.cpu_utilization_high_threshold
  alarm_description   = "CPU High for ECS service ${var.ecs_service_name}"
  alarm_actions       = [var.alarms_sns_topic_arn]
  ok_actions          = [var.alarms_sns_topic_arn]
  dimensions = {
    "ClusterName" = var.ecs_cluster_name
    "ServiceName" = var.ecs_service_name
  }
}

/*
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low" {
  alarm_name          = "${var.ecs_service_name}_cpu_utilization_low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = local.cpu_utilization_low_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = local.cpu_utilization_low_period
  statistic           = "Average"
  threshold           = local.cpu_utilization_low_threshold
  alarm_description   = "CPU Low for ECS service ${var.ecs_service_name}"
  alarm_actions       = [var.alarms_sns_topic_arn]
  ok_actions          = [var.alarms_sns_topic_arn]

  dimensions = {
    "ClusterName" = var.ecs_cluster_name
    "ServiceName" = var.ecs_service_name
  }
}
*/

resource "aws_cloudwatch_metric_alarm" "memory_utilization_high" {
  alarm_name          = "${var.ecs_service_name}_memory_utilization_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = local.memory_utilization_high_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = local.memory_utilization_high_period
  statistic           = "Average"
  threshold           = local.memory_utilization_high_threshold
  alarm_description   = "Memory High for ECS service ${var.ecs_service_name}"
  alarm_actions       = [var.alarms_sns_topic_arn]
  ok_actions          = [var.alarms_sns_topic_arn]

  dimensions = {
    "ClusterName" = var.ecs_cluster_name
    "ServiceName" = var.ecs_service_name
  }
}

/*
resource "aws_cloudwatch_metric_alarm" "memory_utilization_low" {
  alarm_name          = "${var.ecs_service_name}_memory_utilization_low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = local.memory_utilization_low_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = local.memory_utilization_low_period
  statistic           = "Average"
  threshold           = local.memory_utilization_low_threshold
  alarm_description   = "Memory Low for ECS service ${var.ecs_service_name}"
  alarm_actions       = [var.alarms_sns_topic_arn]
  ok_actions          = [var.alarms_sns_topic_arn]

  dimensions = {
    "ClusterName" = var.ecs_cluster_name
    "ServiceName" = var.ecs_service_name
  }
}
*/