locals {
  microservices = ["interop-be-probing-api", "interop-be-probing-caller", "interop-be-probing-eservice-operations",
    "interop-be-probing-eservice-registry-reader", "interop-be-probing-eservice-registry-updater",
  "interop-be-probing-response-updater", "interop-be-probing-scheduler", "interop-be-probing-telemetry-writer", "interop-be-probing-statistics-api"]

  lambda_functions = [
    aws_lambda_function.cognito_authorizer.function_name,
    aws_lambda_function.external_authorizer.function_name,
    aws_lambda_function.cognito_messaging.function_name,
  ]
  sqs_queues = [
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
  evaluation_periods  = 3
  datapoints_to_alarm = 2
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

resource "aws_cloudwatch_metric_alarm" "sqs_message_age_registry_queue" {
  treat_missing_data  = "notBreaching"
  alarm_name          = "${var.app_name}-sqs-message-age-${module.sqs_registry_queue.queue_name}-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 2
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Average"
  dimensions = {
    QueueName = module.sqs_registry_queue.queue_name
  }
  threshold     = var.cw_alarm_thresholds.sqs_message_age_registry_queue
  alarm_actions = [aws_sns_topic.cw_alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each            = toset(local.lambda_functions)
  treat_missing_data  = "notBreaching"
  alarm_name          = "${var.app_name}-${each.value}-errors-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
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
  treat_missing_data  = "notBreaching"
  alarm_name          = "${var.app_name}-lambda-conc-util-pct-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 60
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  alarm_actions       = [aws_sns_topic.cw_alarms.arn]

  metric_query {
    id          = "sq"
    expression  = "conc_util / SERVICE_QUOTA(conc_util) * 100"
    return_data = true
    label       = "LambdaConcurrencyUtilization"
  }

  metric_query {
    id          = "conc_util"
    return_data = false

    metric {
      metric_name = "ConcurrentExecutions"
      namespace   = "AWS/Lambda"
      stat        = "Average"
      period      = 60
    }
  }
}


resource "aws_cloudwatch_metric_alarm" "apigw_server_errors" {
  alarm_name          = "${var.app_name}-apigw-5xx-${var.env}"
  treat_missing_data  = "notBreaching"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.cw_alarms.arn]
}

resource "aws_cloudwatch_log_metric_filter" "error_logs" {

  name           = "${var.app_name}-error-logs-filter-${var.env}"
  pattern        = "{ $.log = \"*ERROR*\" || $.stream = \"stderr\" }"
  log_group_name = "/aws/eks/${module.eks.cluster_name}/application"

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
  for_each            = toset(local.microservices)
  alarm_name          = "${var.app_name}-${each.value}-app-errors-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  evaluation_periods  = 10
  datapoints_to_alarm = 1
  metric_name         = "ErrorCount"
  namespace           = "EKSApplicationLogsFilters"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.cw_alarms.arn]
  dimensions = {
    PodApp = each.value
  }
}



resource "aws_cloudwatch_metric_alarm" "timestream_errors" {
  alarm_name          = "${var.app_name}-timestream-system-errors-${var.env}"
  treat_missing_data  = "notBreaching"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 10
  datapoints_to_alarm = 1
  metric_name         = "SystemErrors"
  namespace           = "AWS/Timestream"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.cw_alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_usage_microservices" {
  for_each            = toset(local.microservices)
  alarm_name          = "${var.app_name}-${each.value}-pod-cpu-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 2
  metric_name         = "pod_cpu_utilization_over_pod_limit"
  namespace           = "ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = var.cw_alarm_thresholds.pod_cpu_utilization
  alarm_actions       = [aws_sns_topic.cw_alarms.arn]
  dimensions = {
    Service     = each.value
    Namespace   = var.env
    ClusterName = module.eks.cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "ram_usage_microservices" {
  for_each            = toset(local.microservices)
  alarm_name          = "${var.app_name}-${each.value}-pod-memory-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 2
  metric_name         = "pod_memory_utilization_over_pod_limit"
  namespace           = "ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = var.cw_alarm_thresholds.pod_memory_utilization
  alarm_actions       = [aws_sns_topic.cw_alarms.arn]
  dimensions = {
    Service     = each.value
    Namespace   = var.env
    ClusterName = module.eks.cluster_name
  }
}