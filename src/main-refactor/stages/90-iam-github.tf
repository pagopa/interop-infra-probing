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

data "aws_iam_policy_document" "backoffice_users_github_repo_assume" {
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

      values = [format("repo:%s:*", var.backoffice_users_repo_name)]
    }
  }
}

resource "aws_iam_role" "backoffice_users_github_repo" {
  name = format("%s-backoffice-users-github-repo-%s", local.project, var.stage)

  assume_role_policy = data.aws_iam_policy_document.backoffice_users_github_repo_assume.json
}

resource "aws_iam_role_policy_attachment" "backoffice_users_github_repo" {
  role       = aws_iam_role.backoffice_users_github_repo.name
  policy_arn = aws_iam_policy.backoffice_users_github_repo.arn
}

resource "aws_iam_policy" "backoffice_users_github_repo" {
  name = "ProbingBackofficeUsersGithubRepo${title(var.stage)}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = format("%s/%s/interop-probing-backoffice-users/backoffice-users.tfstate", data.aws_s3_bucket.terraform_states.arn, var.stage)
      },
      {
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = [data.aws_s3_bucket.terraform_states.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = [data.aws_dynamodb_table.terraform_lock.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:DescribeUserPool",
          "cognito-idp:GetGroup",
          "cognito-idp:ListGroups",
          "cognito-idp:AdminCreateUser",
          "cognito-idp:AdminSetUserPassword",
          "cognito-idp:AdminUpdateUserAttributes",
          "cognito-idp:AdminGetUser",
          "cognito-idp:AdminDeleteUser",
          "cognito-idp:AdminAddUserToGroup",
          "cognito-idp:AdminRemoveUserFromGroup",
          "cognito-idp:AdminListGroupsForUser"
        ]
        Resource = aws_cognito_user_pool.user_pool.arn
      }
    ]
  })
}
