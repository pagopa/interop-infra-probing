data "aws_iam_policy_document" "allow_cloudfront_well_known" {
  statement {
    sid = "AllowCloudFrontServicePrincipalReadOnly"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
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
      "${module.well_known_s3_bucket.s3_bucket_arn}",
      "${module.well_known_s3_bucket.s3_bucket_arn}/*"
    ]
  }
}
module "well_known_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.8.2"

  bucket = "${var.app_name}-well-known-${var.env}"

  attach_policy = true
  policy        = data.aws_iam_policy_document.allow_cloudfront_well_known.json

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    status = false
  }

}
