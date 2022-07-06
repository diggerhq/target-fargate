locals {
  http_error_code_count_high_evaluation_periods = 1
  http_error_code_count_high_period             = 60
  treat_missing_data                            = "ignore"

  thresholds = {
    target_3xx_count     = var.target_3xx_count_threshold
    target_4xx_count     = var.target_4xx_count_threshold
    target_5xx_count     = var.target_5xx_count_threshold
    elb_5xx_count        = var.elb_5xx_count_threshold
    target_response_time = var.target_response_time_threshold
  }

  target_group_dimensions_map = {
    "TargetGroup"  = var.target_group_arn_suffix
    "LoadBalancer" = var.alb_arn_suffix
  }

  load_balancer_dimensions_map = {
    "LoadBalancer" = var.alb_arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "httpcode_target_3xx_count_high" {
  alarm_name          = "${var.ecs_service_name}_lb_target_3xx_count_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = local.http_error_code_count_high_evaluation_periods
  metric_name         = "HTTPCode_Target_3XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = local.http_error_code_count_high_period
  statistic           = "Sum"
  threshold           = local.thresholds["target_3xx_count"]
  treat_missing_data  = local.treat_missing_data
  alarm_description   = "HTTP code 3xx is high for ${var.ecs_service_name}'s lb target over ${local.thresholds["target_response_time"]} last ${local.http_error_code_count_high_period} minute(s) over ${local.http_error_code_count_high_evaluation_periods} period(s)"

  alarm_actions = [var.alarms_sns_topic_arn]
  ok_actions    = [var.alarms_sns_topic_arn]
  dimensions    = local.target_group_dimensions_map
  tags          = var.tags
}

resource "aws_cloudwatch_metric_alarm" "httpcode_target_4xx_count_high" {
  alarm_name          = "${var.ecs_service_name}_lb_target_4xx_count_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = local.http_error_code_count_high_evaluation_periods
  metric_name         = "HTTPCode_Target_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = local.http_error_code_count_high_period
  statistic           = "Sum"
  threshold           = local.thresholds["target_4xx_count"]
  treat_missing_data  = local.treat_missing_data
  alarm_description   = "HTTP code 4xx is high for ${var.ecs_service_name}'s lb target over ${local.thresholds["target_response_time"]} last ${local.http_error_code_count_high_period} minute(s) over ${local.http_error_code_count_high_evaluation_periods} period(s)"

  alarm_actions = [var.alarms_sns_topic_arn]
  ok_actions    = [var.alarms_sns_topic_arn]
  dimensions    = local.target_group_dimensions_map
  tags          = var.tags
}

resource "aws_cloudwatch_metric_alarm" "httpcode_target_5xx_count_high" {
  alarm_name          = "${var.ecs_service_name}_lb_target_5xx_count_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = local.http_error_code_count_high_evaluation_periods
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = local.http_error_code_count_high_period
  statistic           = "Sum"
  threshold           = local.thresholds["target_5xx_count"]
  treat_missing_data  = local.treat_missing_data
  alarm_description   = "HTTP code 5xx is high for ${var.ecs_service_name}'s lb target over ${local.thresholds["target_response_time"]} last ${local.http_error_code_count_high_period} minute(s) over ${local.http_error_code_count_high_evaluation_periods} period(s)"

  alarm_actions = [var.alarms_sns_topic_arn]
  ok_actions    = [var.alarms_sns_topic_arn]
  dimensions    = local.target_group_dimensions_map
  tags          = var.tags
}

resource "aws_cloudwatch_metric_alarm" "httpcode_elb_5xx_count_high" {
  alarm_name          = "${var.ecs_service_name}_elb_5xx_count_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = local.http_error_code_count_high_evaluation_periods
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = local.http_error_code_count_high_period
  statistic           = "Sum"
  threshold           = local.thresholds["elb_5xx_count"]
  treat_missing_data  = local.treat_missing_data
  alarm_description   = "HTTP code 5xx is high for ${var.ecs_service_name}'s elb over ${local.thresholds["target_response_time"]} last ${local.http_error_code_count_high_period} minute(s) over ${local.http_error_code_count_high_evaluation_periods} period(s)"

  alarm_actions = [var.alarms_sns_topic_arn]
  ok_actions    = [var.alarms_sns_topic_arn]
  dimensions    = local.load_balancer_dimensions_map
  tags          = var.tags
}

resource "aws_cloudwatch_metric_alarm" "target_response_time_average_high" {
  alarm_name          = "${var.ecs_service_name}_lb_target_response_time_average_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = local.http_error_code_count_high_evaluation_periods
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = local.http_error_code_count_high_period
  statistic           = "Average"
  threshold           = local.thresholds["target_response_time"]
  treat_missing_data  = local.treat_missing_data
  alarm_description   = "Target Response Time average is high for ${var.ecs_service_name} over ${local.thresholds["target_response_time"]} last ${local.http_error_code_count_high_period} minute(s) over ${local.http_error_code_count_high_evaluation_periods} period(s)"
  alarm_actions       = [var.alarms_sns_topic_arn]
  ok_actions          = [var.alarms_sns_topic_arn]
  dimensions          = local.target_group_dimensions_map
  tags                = var.tags
}
