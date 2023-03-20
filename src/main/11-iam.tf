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