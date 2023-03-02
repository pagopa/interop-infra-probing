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
      data.aws_s3_bucket.interop_probing_bucket.arn,
      "${data.aws_s3_bucket.interop_probing_bucket.arn}/*",
    ]
  }

  statement {
    sid    = "readWriteOnProbingQueue"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucketVersions",
      "s3:ListBucket",
      "s3:GetObjectVersion"
    ]

    resources = [
      module.sqs_registry_queue.queue_arn
    ]
  }

  statement {
    sid    = "listQueues"
    effect = "Allow"
    actions = [
      "sqs:ListQueues"
    ]
    resources = [
      "*"
    ]
  }

}

resource "aws_iam_policy" "registry_reader_policy" {
  name   = "${var.app_name}-be-registry-reader-${var.env}"
  path   = "/infra/eks/pods/"
  policy = data.aws_iam_policy_document.registry_reader_policy.json
}