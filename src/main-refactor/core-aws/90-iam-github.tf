data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "github_monorepo_assume" {
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

      values = [
        "repo:${var.project_monorepo_name}:*",
      ]
    }
  }
}

resource "aws_iam_role" "github_monorepo" {
  name = format("%s-github-monorepo-%s", local.project, var.env)

  assume_role_policy = data.aws_iam_policy_document.github_monorepo_assume.json

  inline_policy {
    name = "GithubEcrPolicy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = "ecr:GetAuthorizationToken"
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecr:CompleteLayerUpload",
            "ecr:GetDownloadUrlForLayer",
            "ecr:InitiateLayerUpload",
            "ecr:PutImage",
            "ecr:UploadLayerPart"
          ]
          Resource = "*"
        }
      ]
    })
  }
}

data "aws_iam_policy_document" "github_assume_ecs" {
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

      values = formatlist("repo:%s:*", toset(var.github_runners_allowed_repos))
    }
  }
}

resource "aws_iam_role" "github_ecs" {
  name = format("%s-github-ecs-%s", local.project, var.env)

  assume_role_policy = data.aws_iam_policy_document.github_assume_ecs.json

  inline_policy {
    name = "GithubEcsPolicy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = "ecs:RunTask"
          Resource = [
            aws_ecs_task_definition.github_runner.arn_without_revision,
            "${aws_ecs_task_definition.github_runner.arn_without_revision}:*"
          ]
          Condition = {
            StringEquals = {
              "ecs:cluster" = aws_ecs_cluster.github_runners.arn
            }
          }
        },
        {
          Effect   = "Allow"
          Action   = "ecs:StopTask"
          Resource = "*"
          Condition = {
            StringEquals = {
              "ecs:cluster" = aws_ecs_cluster.github_runners.arn
            }
          }
        },
        {
          Effect = "Allow"
          Action = "iam:PassRole"
          Resource = [
            aws_iam_role.github_runner_task_exec.arn,
            aws_iam_role.github_runner_task.arn
          ]
        }
      ]
    })
  }
}

data "aws_s3_bucket" "terraform_states" {
  bucket = format("terraform-backend-%s-es1", data.aws_caller_identity.current.account_id)
}

data "aws_dynamodb_table" "terraform_lock" {
  name = "terraform-lock"
}

data "aws_iam_policy_document" "deployment_github_repo_assume" {
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

      values = [format("repo:%s:*", var.deployment_repo_name)]
    }
  }

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.github_runner_task.arn]
    }
  }
}

locals {
  deployment_github_repo_iam_role_name = format("%s-deployment-github-repo-%s", local.project, var.env)
  deployment_github_repo_iam_role_arn  = format("arn:aws:iam::%s:role/%s", data.aws_caller_identity.current.account_id, local.deployment_github_repo_iam_role_name)
}

resource "aws_iam_role" "deployment_github_repo" {
  name = local.deployment_github_repo_iam_role_name

  assume_role_policy = data.aws_iam_policy_document.deployment_github_repo_assume.json
}

resource "aws_iam_role_policy_attachment" "deployment_github_repo" {
  role       = aws_iam_role.deployment_github_repo.name
  policy_arn = aws_iam_policy.deployment_github_repo.arn
}

resource "aws_iam_policy" "deployment_github_repo" {
  depends_on = [module.eks]

  name = "DeploymentGithubRepo"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = flatten([
          for stage in var.stages_to_provision : [
            "${data.aws_s3_bucket.terraform_states.arn}/${stage}/interop-probing-deployment/monitoring.tfstate", #For each stage, there will be a monitoring.tfstate in the dedicated stage folder
            "${data.aws_s3_bucket.terraform_states.arn}/${stage}/interop-probing-deployment/secrets.tfstate"     #For each stage, there will be a secrets.tfstate in the dedicated stage folder
          ]
        ])
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
          "eks:DescribeCluster"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:ListSecrets",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetResourcePolicy"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/EKSClusterName" = module.eks.cluster_name,
            "aws:ResourceTag/TerraformState" = "stages"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:ListTagsForResource"
        ]
        Resource = format("arn:aws:cloudwatch:%s:%s:alarm:*", var.aws_region, data.aws_caller_identity.current.account_id)
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricAlarm"
        ]
        Resource = format("arn:aws:cloudwatch:%s:%s:alarm:*", var.aws_region, data.aws_caller_identity.current.account_id)
        Condition = {
          StringEqualsIfExists = {
            "aws:ResourceTag/Source" = format("https://github.com/%s", var.deployment_repo_name)
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:TagResource"
        ]
        Resource = format("arn:aws:cloudwatch:%s:%s:alarm:*", var.aws_region, data.aws_caller_identity.current.account_id)
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Source" = format("https://github.com/%s", var.deployment_repo_name),
          },
          StringEqualsIfExists = {
            "aws:RequestTag/Source" = format("https://github.com/%s", var.deployment_repo_name)
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:UntagResource"
        ]
        Resource = format("arn:aws:cloudwatch:%s:%s:alarm:*", var.aws_region, data.aws_caller_identity.current.account_id)
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Source" = format("https://github.com/%s", var.deployment_repo_name),
          },
          StringNotEqualsIfExists = {
            "aws:RequestTagKeys" = ["Source"]
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:DescribeAlarms"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:DeleteAlarms"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Source" = format("https://github.com/%s", var.deployment_repo_name)
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:GetDashboard",
          "cloudwatch:PutDashboard",
          "cloudwatch:DeleteDashboards"
        ]
        Resource = format("arn:aws:cloudwatch::%s:dashboard/k8s-*", data.aws_caller_identity.current.account_id)
      },
      {
        Effect = "Allow"
        Action = [
          "logs:DescribeMetricFilters"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:ListTopics"
        ]
        Resource = "*"
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
  name = format("%s-backoffice-users-github-repo-%s", local.project, var.env)

  assume_role_policy = data.aws_iam_policy_document.backoffice_users_github_repo_assume.json
}

resource "aws_iam_role_policy_attachment" "backoffice_users_github_repo" {
  role       = aws_iam_role.backoffice_users_github_repo.name
  policy_arn = aws_iam_policy.backoffice_users_github_repo.arn
}

resource "aws_iam_policy" "backoffice_users_github_repo" {
  name = "BackofficeUsersGithubRepo"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = flatten([
          for stage in var.stages_to_provision : [
            "${data.aws_s3_bucket.terraform_states.arn}/${stage}/interop-probing-backoffice-users/backoffice-users.tfstate"
          ]
        ])
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
        Resource = flatten([
          for cognito_user_pool_id in var.cognito_user_pool_ids : [
            format("arn:aws:cognito-idp:%s:%s:userpool/%s", var.aws_region, data.aws_caller_identity.current.account_id, cognito_user_pool_id)
          ]
        ])
      }
    ]
  })
}
