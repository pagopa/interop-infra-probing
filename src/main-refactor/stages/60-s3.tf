module "apigw_openapi_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket = format("%s-apigw-openapi-%s", local.project, var.stage)

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }
}

module "alb_logs_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket = format("%s-alb-logs-%s", local.project, var.stage)

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }

  lifecycle_rule = [
    {
      id         = "TransitionToStandardIA"
      enabled    = true
      transition = { days = 30, storage_class = "STANDARD_IA" }
    }
  ]

  attach_policy = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          "AWS" = "arn:aws:iam::635631232127:root" # ELB account id for eu-south-1. See https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
        }
        Action   = "s3:PutObject"
        Resource = "${module.alb_logs_bucket.s3_bucket_arn}/*"
      }
    ]
  })
}

module "well_known_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket = format("%s-well-known-%s", local.project, var.stage)

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = false #TOCHECK
  }

  attach_policy = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${module.well_known_bucket.s3_bucket_arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = module.fe_cdn.cloudfront_distribution_arn
          }
        }
      }
    ]
  })
}

module "fe_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket = format("%s-fe-hosting-%s", local.project, var.stage)

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = false #TOCHECK
  }

  attach_policy = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${module.fe_bucket.s3_bucket_arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = module.fe_cdn.cloudfront_distribution_arn
          }
        }
      }
    ]
  })
}
