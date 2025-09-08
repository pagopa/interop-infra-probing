resource "aws_cloudwatch_metric_alarm" "sqs_poll" {
  depends_on = [aws_sqs_queue.poll]

  alarm_name          = "sqs-${aws_sqs_queue.poll.name}-message-age"
  alarm_description   = "Age of oldest message in the queue"
  period              = "60"
  evaluation_periods  = "5"
  datapoints_to_alarm = "1"
  statistic           = "Maximum"
  threshold           = "120" # 2 minutes
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  alarm_actions       = [aws_sns_topic.platform_alarms.arn]
  treat_missing_data  = "notBreaching"
  dimensions = {
    QueueName = aws_sqs_queue.poll.name
  }
}

resource "aws_cloudwatch_metric_alarm" "telemetry_record" {
  depends_on = [aws_sqs_queue.telemetry_record]

  alarm_name          = "sqs-${aws_sqs_queue.telemetry_record.name}-message-age"
  alarm_description   = "Age of oldest message in the queue"
  period              = "60"
  evaluation_periods  = "5"
  datapoints_to_alarm = "1"
  statistic           = "Maximum"
  threshold           = "120" # 2 minutes
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  alarm_actions       = [aws_sns_topic.platform_alarms.arn]
  treat_missing_data  = "notBreaching"
  dimensions = {
    QueueName = aws_sqs_queue.telemetry_record.name
  }
}

resource "aws_cloudwatch_metric_alarm" "response_received" {
  depends_on = [aws_sqs_queue.response_received]

  alarm_name          = "sqs-${aws_sqs_queue.response_received.name}-message-age"
  alarm_description   = "Age of oldest message in the queue"
  period              = "60"
  evaluation_periods  = "5"
  datapoints_to_alarm = "1"
  statistic           = "Maximum"
  threshold           = "120" # 2 minutes
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  alarm_actions       = [aws_sns_topic.platform_alarms.arn]
  treat_missing_data  = "notBreaching"
  dimensions = {
    QueueName = aws_sqs_queue.response_received.name
  }
}

#TODO: Add alarms for lambda functions (Errors metric) and for Timestream (SystemErrors metric) 