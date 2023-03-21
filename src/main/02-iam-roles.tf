data "aws_iam_policy_document" "frontend_deploy_permission" {
  statement {
    sid    = "CreateInvalidation"
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation"
    ]

    resources = [
      module.fe_cdn.cloudfront_distribution_arn
    ]
  }
  statement {
    sid    = "ManageObjects"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${module.fe_s3_bucket.s3_bucket_arn}/*"
    ]
  }
  statement {
    sid    = "ManageBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      module.fe_s3_bucket.s3_bucket_arn
    ]
  }


}




resource "aws_iam_policy" "registry_updater_policy" {
  name   = "${var.be_prefix}-frontend-deploy-permission-${var.env}"
  path   = "/infra/github/pipelines/"
  policy = data.aws_iam_policy_document.frontend_deploy_permission.json
}