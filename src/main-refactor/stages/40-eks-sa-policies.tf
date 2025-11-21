locals {
  msk_iam_prefix = try(replace(split("/", var.interop_msk_cluster_arn)[0], ":cluster", ""), "")

  interop_msk_cluster_name = try(split("/", var.interop_msk_cluster_arn)[1], "")
  interop_msk_cluster_uuid = try(split("/", var.interop_msk_cluster_arn)[2], "")

  msk_topic_iam_prefix = "${local.msk_iam_prefix}:topic/${local.interop_msk_cluster_name}/${local.interop_msk_cluster_uuid}"
  msk_group_iam_prefix = "${local.msk_iam_prefix}:group/${local.interop_msk_cluster_name}/${local.interop_msk_cluster_uuid}"
}

resource "aws_iam_policy" "be_scheduler" {
  name = "ProbingBeScheduler-${var.stage}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "WriteOnPollQueue"
        Effect   = "Allow"
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.poll.arn
      }
    ]
  })
}

resource "aws_iam_policy" "be_telemetry_writer" {
  name = "ProbingBeTelemetryWriter-${var.stage}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadAndDeleteFromTelemetryRecordQueue"
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = aws_sqs_queue.telemetry_record.arn
      },
      {
        Sid    = "GetTimestreamInstance"
        Effect = "Allow"
        Action = [
          "timestream-influxdb:GetDbInstance"
        ]
        Resource = "arn:aws:timestream-influxdb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:db-instance/${var.timestream_instance_id}"
      }
    ]
  })
}

resource "aws_iam_policy" "be_caller" {
  name = "ProbingBeCaller-${var.stage}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadAndDeleteMsgFromPollQueue"
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = aws_sqs_queue.poll.arn
      },
      {
        Sid    = "WriteMsgToQueues"
        Effect = "Allow"
        Action = "sqs:SendMessage"
        Resource = [
          aws_sqs_queue.response_received.arn,
          aws_sqs_queue.telemetry_record.arn
        ]
      },
      {
        Sid      = "SignKey"
        Effect   = "Allow"
        Action   = "kms:Sign"
        Resource = aws_kms_key.jwt_sign.arn
      }
    ]
  })
}

resource "aws_iam_policy" "be_response_updater" {
  name = "ProbingBeResponseUpdater-${var.stage}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadAndDeleteMsgFromResponseReceivedQueue"
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = aws_sqs_queue.response_received.arn
      }
    ]
  })
}

resource "aws_iam_policy" "be_statistics_api" {
  name = "ProbingBeStatisticsApi-${var.stage}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "GetTimestreamInstance"
        Effect = "Allow"
        Action = [
          "timestream-influxdb:GetDbInstance"
        ]
        Resource = "arn:aws:timestream-influxdb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:db-instance/${var.timestream_instance_id}"
      }
    ]
  })
}

resource "aws_iam_policy" "be_eservice_event_consumer" {
  count = local.deploy_interop_msk_integration ? 1 : 0

  name = "ProbingBeEserviceEventConsumer"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ConnectToMSKAndReadCatalogEventsTopic"
        Effect = "Allow"
        Action = [
          "kafka-cluster:AlterGroup",
          "kafka-cluster:Connect",
          "kafka-cluster:DescribeGroup",
          "kafka-cluster:DescribeTopic",
          "kafka-cluster:ReadData"
        ]
        Resource = [
          var.interop_msk_cluster_arn,
          "${local.msk_topic_iam_prefix}/outbound.*_catalog.events",
          "${local.msk_group_iam_prefix}/probing-${var.env}*-eservice-event-consumer"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "be_tenant_event_consumer" {
  count = local.deploy_interop_msk_integration ? 1 : 0

  name = "ProbingBeTenantEventConsumer"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ConnectToMSKAndReadTenantEventsTopic"
        Effect = "Allow"
        Action = [
          "kafka-cluster:AlterGroup",
          "kafka-cluster:Connect",
          "kafka-cluster:DescribeGroup",
          "kafka-cluster:DescribeTopic",
          "kafka-cluster:ReadData"
        ]
        Resource = [
          var.interop_msk_cluster_arn,
          "${local.msk_topic_iam_prefix}/outbound.*_tenant.events",
          "${local.msk_group_iam_prefix}/probing-${var.env}*-tenant-event-consumer"
        ]
      }
    ]
  })
}