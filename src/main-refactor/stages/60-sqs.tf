resource "aws_sqs_queue" "poll" {
  name = format("%s-poll-%s", local.project, var.stage)

  message_retention_seconds = 1209600 # 14 days
  max_message_size          = 262144  # 256 KB
}

resource "aws_sqs_queue" "telemetry_record" {
  name = format("%s-telemetry-record-%s", local.project, var.stage)

  message_retention_seconds = 1209600 # 14 days
  max_message_size          = 262144  # 256 KB
}

resource "aws_sqs_queue" "response_received" {
  name = format("%s-response-received-%s", local.project, var.stage)

  message_retention_seconds = 1209600 # 14 days
  max_message_size          = 262144  # 256 KB
}
