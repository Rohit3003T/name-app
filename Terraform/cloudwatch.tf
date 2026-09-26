resource "aws_cloudwatch_metric_alarm" "app_cpu_high" {
  alarm_name          = "name-app-high-cpu"
  alarm_description   = "App ASG CPU utilization is too high"
  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 2
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"

  period    = 300
  statistic = "Average"
  threshold = 80

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }

  treat_missing_data = "notBreaching"
}



resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_targets" {
  alarm_name          = "name-app-unhealthy-targets"
  alarm_description   = "ALB has unhealthy application targets"
  comparison_operator = "LessThanThreshold"

  evaluation_periods = 2
  metric_name        = "HealthyHostCount"
  namespace          = "AWS/ApplicationELB"

  period    = 60
  statistic = "Minimum"
  threshold = 1

  dimensions = {
    TargetGroup  = aws_lb_target_group.app_tg.arn_suffix
    LoadBalancer = aws_lb.app_alb.arn_suffix
  }

  treat_missing_data = "breaching"
}



resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "name-app-rds-high-cpu"
  alarm_description   = "RDS CPU utilization is too high"
  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 2
  metric_name        = "CPUUtilization"
  namespace          = "AWS/RDS"

  period    = 300
  statistic = "Average"
  threshold = 80

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.app_db.id
  }

  treat_missing_data = "notBreaching"
}

