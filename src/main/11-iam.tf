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
  name   = "${var.app_name}-be-registry-reader-${var.env}"
  path   = "/infra/eks/pods/"
  policy = data.aws_iam_policy_document.registry_reader_policy.json
}