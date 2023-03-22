data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "github_frontend_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      values = [var.frontend_github_repo]
    }
  }

}

data "aws_iam_policy_document" "frontend_deploy" {
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

resource "aws_iam_policy" "frontend_deploy_permission" {
  name   = "${var.be_prefix}-frontend-deploy-${var.env}"
  path   = "/infra/github/pipelines/"
  policy = data.aws_iam_policy_document.frontend_deploy.json
}

resource "aws_iam_role" "frontend_github_pipeline" {
  name = "${var.be_prefix}-frontend-deploy-${var.env}"

  assume_role_policy = data.aws_iam_policy_document.github_frontend_assume.json

  managed_policy_arns = [
    aws_iam_policy.frontend_deploy_permission.arn
  ]

}
