locals {
  microservices = ["interop-probing-api", "interop-probing-caller", "interop-probing-eservice-operations",
    "interop-probing-eservice-registry-reader", "interop-probing-eservice-registry-updater",
  "interop-probing-response-updater", "interop-probing-scheduler", "interop-probing-telemetry-writer", "interop-probing-statistics-api"]

  lambda_functions = [
    aws_lambda_function.cognito_authorizer.function_name,
    aws_lambda_function.external_authorizer.function_name,
    aws_lambda_function.cognito_messaging.function_name,
  ]
  sqs_queues = [
    module.sqs_registry_queue.queue_name,
    module.sqs_polling_queue.queue_name,
    module.sqs_polling_result_queue.queue_name,
    module.sqs_telemetry_result_queue.queue_name
  ]

}

resource "aws_cloudwatch_metric_alarm" "sqs_message_age" {
  for_each            = toset(local.sqs_queues)
  treat_missing_data  = "notBreaching"
  alarm_name          = "${var.app_name}-sqs-message-age-${each.value}-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 10
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Average"
  dimensions = {
    QueueName = each.value
  }
  threshold     = var.cw_alarm_thresholds.sqs_message_age
  alarm_actions = [aws_sns_topic.cw_alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each            = toset(local.lambda_functions)
  treat_missing_data  = "notBreaching"
  alarm_name          = "${var.app_name}-lambda-errors-${each.value}-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 10
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"

  dimensions = {
    FunctionName = each.value
  }
  threshold     = 1
  alarm_actions = [aws_sns_topic.cw_alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_concurrency_pct" {
  for_each            = toset(local.lambda_functions)
  treat_missing_data  = "notBreaching"
  alarm_name          = "${var.app_name}-lambda-conc-util-pct-${each.value}-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ProvisionedConcurrencyUtilization"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Maximum"
  threshold           = var.cw_alarm_thresholds.lambda_concurrency_utilization
  alarm_actions       = [aws_sns_topic.cw_alarms.arn]
}


resource "aws_cloudwatch_metric_alarm" "apigw_server_errors" {
  alarm_name          = "${var.app_name}-apigw-5xx-${var.env}"
  treat_missing_data  = "notBreaching"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 10
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.cw_alarms.arn]
}

resource "aws_cloudwatch_log_metric_filter" "error_logs" {

  name           = "${var.app_name}-error-logs-filter-${var.env}"
  pattern        = "ERROR"
  log_group_name = "/aws/eks/interop-probing-eks-dev/application"

  metric_transformation {
    name      = "ErrorCount"
    namespace = "EKSApplicationLogsFilters"
    value     = "1"

    dimensions = {
      PodApp = "$.pod_app"
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "error_logs" {
  alarm_name          = "${var.app_name}-application-errors-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 10
  metric_name         = "ErrorCount"
  namespace           = "ApplicationLogs"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.cw_alarms.arn]
}




resource "aws_cloudwatch_metric_alarm" "timestream_errors" {
  alarm_name          = "${var.app_name}-timestream-system-errors-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 10
  metric_name         = "SystemErrors"
  namespace           = "AWS/Timestream"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.cw_alarms.arn]
}