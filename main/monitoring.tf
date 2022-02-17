data "aws_caller_identity" "current" {}

locals {

  cpu_utilization_high_threshold    = 80
  cpu_utilization_low_threshold     = 0
  memory_utilization_high_threshold = 100
  memory_utilization_low_threshold  = 0
  monitoring_sns_topic_arn          = "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:cloudwatch_alarms"

  monitoring_enabled                         = var.monitoring_enabled ? 1 : 0
  cpu_utilization_high_evaluation_periods    = 1
  cpu_utilization_high_period                = 60
  cpu_utilization_low_evaluation_periods     = 1
  cpu_utilization_low_period                 = 60
  memory_utilization_high_evaluation_periods = 1
  memory_utilization_high_period             = 60
  memory_utilization_low_evaluation_periods  = 1
  memory_utilization_low_period              = 60

  cluster_name = aws_ecs_cluster.app.name
  service_name = "{{service_name}}"

  dimensions_map = {
    "service" = {
      "ClusterName" = local.cluster_name
      "ServiceName" = local.service_name
    }
    "cluster" = {
      "ClusterName" = local.cluster_name
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  count               = local.monitoring_enabled
  alarm_name          = "${var.app}_cpu_utilization_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = local.cpu_utilization_high_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = local.cpu_utilization_high_period
  statistic           = "Average"
  threshold           = local.cpu_utilization_high_threshold
  alarm_description   = "CPU High for ECS service ${local.service_name}"
  alarm_actions       = [var.alarms_sns_topic_arn]
  ok_actions          = [var.alarms_sns_topic_arn]
  dimensions = {
    "ClusterName" = local.cluster_name
    "ServiceName" = local.service_name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low" {
  count               = local.monitoring_enabled
  alarm_name          = "${var.app}_cpu_utilization_low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = local.cpu_utilization_low_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = local.cpu_utilization_low_period
  statistic           = "Average"
  threshold           = local.cpu_utilization_low_threshold
  alarm_description   = "CPU Low for ECS service ${local.service_name}"
  alarm_actions       = [var.alarms_sns_topic_arn]
  ok_actions          = [var.alarms_sns_topic_arn]

  dimensions = {
    "ClusterName" = local.cluster_name
    "ServiceName" = local.service_name
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_high" {
  count               = local.monitoring_enabled
  alarm_name          = "${var.app}_memory_utilization_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = local.memory_utilization_high_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = local.memory_utilization_high_period
  statistic           = "Average"
  threshold           = local.memory_utilization_high_threshold
  alarm_description   = "Memory High for ECS service ${local.service_name}"
  alarm_actions       = [var.alarms_sns_topic_arn]
  ok_actions          = [var.alarms_sns_topic_arn]

  dimensions = {
    "ClusterName" = local.cluster_name
    "ServiceName" = local.service_name
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_low" {
  count               = local.monitoring_enabled
  alarm_name          = "${var.app}_memory_utilization_low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = local.memory_utilization_low_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = local.memory_utilization_low_period
  statistic           = "Average"
  threshold           = local.memory_utilization_low_threshold
  alarm_description   = "Memory Low for ECS service ${local.service_name}"
  alarm_actions       = [var.alarms_sns_topic_arn]
  ok_actions          = [var.alarms_sns_topic_arn]

  dimensions = {
    "ClusterName" = local.cluster_name
    "ServiceName" = local.service_name
  }
}