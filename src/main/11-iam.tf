data "aws_iam_policy" "aws_managed_xray_daemon_write_access" {
  name = "AWSXRayDaemonWriteAccess"
}


data "aws_iam_policy" "aws_managed_cloudwatch_agent_server" {
  name = "CloudWatchAgentServerPolicy"
}

data "aws_iam_policy_document" "registry_reader_policy" {
  statement {
    sid    = "GetProbingObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucketVersions",
      "s3:ListBucket",
      "s3:GetObjectVersion"
    ]

    resources = [
      var.interop_probing_bucket_arn,
      "${var.interop_probing_bucket_arn}/*",
    ]
  }

  statement {
    sid    = "WriteOnRegistryQueue"
    effect = "Allow"
    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      module.sqs_registry_queue.queue_arn
    ]
  }

}

resource "aws_iam_policy" "registry_reader_policy" {
  name   = "${var.be_prefix}-registry-reader-${var.env}"
  path   = "/application/eks/pods/"
  policy = data.aws_iam_policy_document.registry_reader_policy.json
}


data "aws_iam_policy_document" "registry_updater_policy" {

  statement {
    sid    = "ReadAndDeleteMsgFromRegistryQueue"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage"
    ]

    resources = [
      module.sqs_registry_queue.queue_arn
    ]
  }


}

resource "aws_iam_policy" "registry_updater_policy" {
  name   = "${var.be_prefix}-registry-updater-${var.env}"
  path   = "/application/eks/pods/"
  policy = data.aws_iam_policy_document.registry_updater_policy.json
}


data "aws_iam_policy_document" "scheduler_policy" {
  statement {
    sid    = "WriteOnPollingQueue"
    effect = "Allow"
    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      module.sqs_polling_queue.queue_arn
    ]
  }


}

resource "aws_iam_policy" "scheduler_policy" {
  name   = "${var.be_prefix}-scheduler-${var.env}"
  path   = "/application/eks/pods/"
  policy = data.aws_iam_policy_document.scheduler_policy.json
}


data "aws_iam_policy_document" "telemetry_writer_policy" {

  statement {
    sid    = "ReadAndDeleteFromTelemetryResultQueue"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]

    resources = [
      module.sqs_telemetry_result_queue.queue_arn
    ]
  }

  statement {
    sid    = "ListTimestreamDatabases"
    effect = "Allow"
    actions = [
      "timestream:ListDatabases",
      "timestream:SelectValues",
      "timestream:DescribeEndpoints"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "WriteOnTimestreamTable"
    effect = "Allow"
    actions = [
      "timestream:WriteRecords",
      "timestream:ListTables",
      "timestream:Select",
      "timestream:UpdateTable"
    ]

    resources = [
      aws_timestreamwrite_table.probing_telemetry.arn
    ]
  }


}

resource "aws_iam_policy" "telemetry_writer_policy" {
  name   = "${var.be_prefix}-telemetry-writer-${var.env}"
  path   = "/application/eks/pods/"
  policy = data.aws_iam_policy_document.telemetry_writer_policy.json
}


data "aws_iam_policy_document" "caller_policy" {

  statement {
    sid    = "ReadAndDeleteMsgFromPollQueue"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]

    resources = [
      module.sqs_polling_queue.queue_arn
    ]
  }

  statement {
    sid    = "WriteMsgToQueues"
    effect = "Allow"
    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      module.sqs_polling_result_queue.queue_arn,
      module.sqs_telemetry_result_queue.queue_arn
    ]
  }

  statement {
    sid     = "Sign"
    effect  = "Allow"
    actions = ["kms:Sign"]

    resources = [aws_kms_key.jwt_sign_key.arn]
  }
}

resource "aws_iam_policy" "caller_policy" {
  name   = "${var.be_prefix}-caller-${var.env}"
  path   = "/application/eks/pods/"
  policy = data.aws_iam_policy_document.caller_policy.json
}


data "aws_iam_policy_document" "response_updater_policy" {

  statement {
    sid    = "ReadAndDeleteMsgFromPollQueue"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]

    resources = [
      module.sqs_polling_result_queue.queue_arn
    ]
  }


}

resource "aws_iam_policy" "response_updater_policy" {
  name   = "${var.be_prefix}-response-updater-${var.env}"
  path   = "/application/eks/pods/"
  policy = data.aws_iam_policy_document.response_updater_policy.json
}


data "aws_iam_policy_document" "statistics_api_policy" {

  statement {
    sid    = "ListTimestreamDatabases"
    effect = "Allow"
    actions = [
      "timestream:ListDatabases",
      "timestream:SelectValues",
      "timestream:DescribeEndpoints",
      "timestream:ListTables",
      "timestream:CancelQuery",
      "timesteam:DescribeDatabase"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "ReadFromTimestreamTable"
    effect = "Allow"
    actions = [
      "timestream:DescribeTable",
      "timestream:Select",
      "timestream:ListMeasures"
    ]

    resources = [
      aws_timestreamwrite_table.probing_telemetry.arn
    ]
  }


}

resource "aws_iam_policy" "statistics_api_policy" {
  name   = "${var.be_prefix}-statistics-api-${var.env}"
  path   = "/application/eks/pods/"
  policy = data.aws_iam_policy_document.statistics_api_policy.json
}

