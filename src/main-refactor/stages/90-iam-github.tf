resource "aws_iam_role_policy_attachment" "s3_sync_deployment_github_repo" {
  role       = data.aws_iam_role.probing_deployment_github_repo_role.name
  policy_arn = aws_iam_policy.s3_sync_deployment_github_repo.arn
}

resource "aws_iam_policy" "s3_sync_deployment_github_repo" {
  depends_on = [module.fe_bucket, module.fe_cdn]
  name       = "S3SyncAndInvalidateCloudFront${title(var.stage)}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = [
          module.fe_bucket.s3_bucket_arn,
          format("%s/*", module.fe_bucket.s3_bucket_arn)
        ]
      },
      {
        Effect   = "Allow"
        Action   = "cloudfront:CreateInvalidation"
        Resource = module.fe_cdn.cloudfront_distribution_arn
      }
    ]
  })
}