data "aws_iam_policy_document" "allow_lambda" {
  statement {
    sid = "AllowCloudFrontServicePrincipalReadOnly"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [
        module.fe_cdn.cloudfront_distribution_arn
      ]
    }
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${module.lambda_packages_bucket.s3_bucket_arn}",
      "${module.lambda_packages_bucket.s3_bucket_arn}/*"
    ]
  }
}
module "lambda_packages_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.8.2"

  bucket = "${var.app_name}-lambda-packages-${var.env}"

  attach_policy = true
  policy        = data.aws_iam_policy_document.allow_lambda.json

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    status = false
  }

}
