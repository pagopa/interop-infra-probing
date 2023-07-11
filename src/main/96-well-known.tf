module "well_known_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.8.2"

  bucket = "${var.app_name}-well-known-${var.env}"

  attach_policy = true
  policy        = data.aws_iam_policy_document.allow_lambda_well_known.json

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  acl = "private"
  versioning = {
    status = false
  }

}

