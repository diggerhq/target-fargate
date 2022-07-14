/**
 * This module sets up CPU-based autoscaling.  The number of containers
 * is kept strictly within the range you specify.  Within that range,
 * the number is gradually increased or decreased to keep CPU utilization
 * within its own range.  If your app is CPU-bound, the number of
 * instances will autoscale with your traffic.
 *
 * The adjustments are gradual.  If you expect a sudden surge of
 * traffic for a scheduled event (such as sporting events or elections),
 * set the `ecs_autoscale_min_instances` variable to a higher number.
 * `ecs_autoscale_max_instances` might also need to be increased, because
 * it should never be below ecs_autoscale_min_instances.
 *
 * To effectively disable autoscaling, set `ecs_autoscale_min_instances`
 * and `ecs_autoscale_max_instances` to the same number (your desired
 * number of containers).
 *
 * Note the default value of `ecs_autoscale_min_instances` is 1.  For
 * production, consider using a higher number.
 *
 * There should be a [considerable gap](https://en.wikipedia.org/wiki/Deadband) between
 * `ecs_as_cpu_low_threshold_per` and
 * `ecs_as_cpu_high_threshold_per` so that the number of
 * containers is not continually being autoscaled up and down.   If
 * `ecs_autoscale_min_instances==1`, then
 * `ecs_as_cpu_high_threshold_per` should be more than
 * twice ecs_as_cpu_low_threshold_per`.
 *
 * In the CloudWatch section of the AWS Console, you will often see the
 * alarms created by this module in an ALARM state, which are displayed in
 * red.  This is normal and does not indicate a problem.
 * On the page listing all the alarms, click the checkbox labelled
 * "Hide all AutoScaling alarms".
 *
 */

# If the average CPU utilization over a minute drops to this threshold,
# the number of containers will be reduced (but not below ecs_autoscale_min_instances).
variable "ecs_as_cpu_low_threshold_per" {
  default = "20"
}

# If the average CPU utilization over a minute rises to this threshold,
# the number of containers will be increased (but not above ecs_autoscale_max_instances).
variable "ecs_as_cpu_high_threshold_per" {
  default = "60"
}

# If the average mem utilization over a minute drops to this threshold,
# the number of containers will be reduced (but not below ecs_autoscale_min_instances).
variable "ecs_as_mem_low_threshold_per" {
  default = "20"
}

# If the average mem utilization over a minute rises to this threshold,
# the number of containers will be increased (but not above ecs_autoscale_max_instances).
variable "ecs_as_mem_high_threshold_per" {
  default = "60"
}

resource "aws_appautoscaling_target" "app_scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.ecs_autoscale_max_instances
  min_capacity       = var.ecs_autoscale_min_instances
}

resource "aws_appautoscaling_policy" "ecs_target_cpu" {
  name               = "application-scaling-policy-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.app_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.app_scale_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.app_scale_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.ecs_as_cpu_high_threshold_per
  }
  depends_on = [aws_appautoscaling_target.app_scale_target]
}

resource "aws_appautoscaling_policy" "ecs_target_memory" {
  name               = "application-scaling-policy-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.app_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.app_scale_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.app_scale_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = var.ecs_as_mem_high_threshold_per
  }
  depends_on = [aws_appautoscaling_target.app_scale_target]
}