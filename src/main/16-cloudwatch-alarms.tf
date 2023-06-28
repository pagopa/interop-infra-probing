locals {
  microservices = ["interop-be-probing-api", "interop-be-probing-caller", "interop-be-probing-eservice-operations",
    "interop-be-probing-eservice-registry-reader", "interop-be-probing-eservice-registry-updater",
  "interop-be-probing-response-updater", "interop-be-probing-scheduler", "interop-be-probing-telemetry-writer", "interop-be-probing-statistics-api"]
}

resource "aws_cloudwatch_metric_alarm" "ms_memory_alarm" {
  for_each            = toset(local.microservices)
  alarm_name          = "${var.app_name}-cwalarm-memory-${each.value}-${var.env}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 10
  metric_name         = "pod_memory_utilization_over_pod_limit"
  namespace           = "ContainerInsights"
  dimensions = {
    Service = each.value
  }
  period        = 60
  statistic     = "Average"
  threshold     = var.cw_alarm_thresholds.memory_threshold
  alarm_actions = [aws_sns_topic.cw_alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "ms_cpu_alarm" {
  for_each            = toset(local.microservices)
  alarm_name          = "${var.app_name}-cwalarm-cpu-${each.value}-${var.env}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 10
  metric_name         = "pod_cpu_usage_total"
  namespace           = "ContainerInsights"
  dimensions = {
    Service = each.value
    ClusterName = module.eks.cluster_name
  }
  period        = 60
  statistic     = "Average"
  threshold     = var.cw_alarm_thresholds.cpu_threshold
  alarm_actions = [aws_sns_topic.cw_alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "apigw_server_errors" {
  alarm_name          = "${var.app_name}-cwalarm-apigw-server-errors-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 10
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 60
  statistic           = "SampleCount"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.cw_alarms.arn]
}

resource "aws_cloudwatch_log_metric_filter" "error_logs" {

  name           = "${var.app_name}-error-logs-filter-${var.env}"
  pattern        = "ERROR"
  log_group_name = "/aws/eks/${module.eks.cluster_name}/application"

  metric_transformation {
    name      = "ErrorCount"
    namespace = "ApplicationLogs"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "error_logs" {
  alarm_name          = "${var.app_name}-cwalarm-application-errors-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 10
  metric_name         = "ErrorCount"
  namespace           = "ApplicationLogs"
  period              = 60
  statistic           = "SampleCount"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.cw_alarms.arn]
}


resource "aws_cloudwatch_metric_alarm" "sqs_message_age" {
  alarm_name          = "${var.app_name}-cwalarm-sqs-message-age-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 10
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Average"
  threshold           = var.cw_alarm_thresholds.sqs_message_age
  alarm_actions       = [aws_sns_topic.cw_alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.app_name}-cwalarm-lambda-errors-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 10
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "SampleCount"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.cw_alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_concurrency_pct" {
  alarm_name          = "${var.app_name}-cwalarm-lambda-concurrency-utilization-pct-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 10
  metric_name         = "ProvisionedConcurrencyUtilization"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Maximum"
  threshold           = var.cw_alarm_thresholds.lambda_concurrency_utilization
  alarm_actions       = [aws_sns_topic.cw_alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "timestream_errors" {
  alarm_name          = "${var.app_name}-cwalarm-timestream-system-errors-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 10
  metric_name         = "SystemErrors"
  namespace           = "AWS/Timestream"
  period              = 60
  statistic           = "SampleCount"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.cw_alarms.arn]
}