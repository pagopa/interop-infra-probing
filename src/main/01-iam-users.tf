locals {
  create_externals = var.env == "dev" || var.env == "uat"
}

data "aws_iam_policy" "read_only" {
  name = "ReadOnlyAccess"
}

data "aws_iam_policy" "iam_user_password" {
  name = "IAMUserChangePassword"
}

data "aws_iam_policy" "secrets_manager_read_write" {
  name = "SecretsManagerReadWrite"
}

data "aws_dynamodb_table" "terraform_lock" {
  name = "terraform-lock"
}

resource "aws_iam_policy" "user_mfa" {
  count = local.create_externals ? 1 : 0

  name = "UserMFASelfService"

  policy = <<-EOT
  {
    "Version": "2012-10-17",
      "Statement": [
      {
        "Sid": "AllowViewAccountInfo",
        "Effect": "Allow",
        "Action": [
          "iam:GetAccountPasswordPolicy",
        "iam:ListVirtualMFADevices"
        ],
        "Resource": "*"
      },
      {
        "Sid": "AllowManageOwnPasswords",
        "Effect": "Allow",
        "Action": [
          "iam:ChangePassword",
        "iam:GetUser"
        ],
        "Resource": "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        "Sid": "AllowManageOwnAccessKeys",
        "Effect": "Allow",
        "Action": [
          "iam:CreateAccessKey",
        "iam:DeleteAccessKey",
        "iam:ListAccessKeys",
        "iam:UpdateAccessKey"
        ],
        "Resource": "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        "Sid": "AllowManageOwnSigningCertificates",
        "Effect": "Allow",
        "Action": [
          "iam:DeleteSigningCertificate",
        "iam:ListSigningCertificates",
        "iam:UpdateSigningCertificate",
        "iam:UploadSigningCertificate"
        ],
        "Resource": "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        "Sid": "AllowManageOwnSSHPublicKeys",
        "Effect": "Allow",
        "Action": [
          "iam:DeleteSSHPublicKey",
        "iam:GetSSHPublicKey",
        "iam:ListSSHPublicKeys",
        "iam:UpdateSSHPublicKey",
        "iam:UploadSSHPublicKey"
        ],
        "Resource": "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        "Sid": "AllowManageOwnGitCredentials",
        "Effect": "Allow",
        "Action": [
          "iam:CreateServiceSpecificCredential",
        "iam:DeleteServiceSpecificCredential",
        "iam:ListServiceSpecificCredentials",
        "iam:ResetServiceSpecificCredential",
        "iam:UpdateServiceSpecificCredential"
        ],
        "Resource": "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        "Sid": "AllowManageOwnVirtualMFADevice",
        "Effect": "Allow",
        "Action": [
          "iam:CreateVirtualMFADevice"
        ],
        "Resource": "arn:aws:iam::*:mfa/*"
      },
      {
        "Sid": "AllowManageOwnUserMFA",
        "Effect": "Allow",
        "Action": [
          "iam:DeactivateMFADevice",
        "iam:EnableMFADevice",
        "iam:ListMFADevices",
        "iam:ResyncMFADevice"
        ],
        "Resource": "arn:aws:iam::*:user/$${aws:username}"
      }
    ]
  }
  EOT
}

resource "aws_iam_group" "external_developers" {
  count = local.create_externals ? 1 : 0

  name = "ExternalDevelopers"
  path = "/externals/"
}

resource "aws_iam_group_policy_attachment" "read_only" {
  count = local.create_externals ? 1 : 0

  group      = aws_iam_group.external_developers[0].name
  policy_arn = data.aws_iam_policy.read_only.arn
}

resource "aws_iam_group_policy_attachment" "iam_user_password" {
  count = local.create_externals ? 1 : 0

  group      = aws_iam_group.external_developers[0].name
  policy_arn = data.aws_iam_policy.iam_user_password.arn
}

resource "aws_iam_group_policy_attachment" "secrets_manager_read_write" {
  count = var.env == "dev" ? 1 : 0

  group      = aws_iam_group.external_developers[0].name
  policy_arn = data.aws_iam_policy.secrets_manager_read_write.arn
}

resource "aws_iam_group_policy_attachment" "user_mfa" {
  count = local.create_externals ? 1 : 0

  group      = aws_iam_group.external_developers[0].name
  policy_arn = aws_iam_policy.user_mfa[0].arn
}

resource "aws_iam_group_policy" "terraform_lock" {
  count = var.env == "dev" ? 1 : 0

  name  = "TerraformLock"
  group = aws_iam_group.external_developers[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem"
        ]
        Effect   = "Allow"
        Resource = data.aws_dynamodb_table.terraform_lock.arn
      }
    ]
  })
}

resource "aws_iam_group_policy" "local_development" {
  count = var.env == "dev" ? 1 : 0

  name  = "LocalDevelopment"
  group = aws_iam_group.external_developers[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "PutObjectOnWellKnownBucket"
        Effect = "Allow"
        Action = [


          "s3:PutObject"
        ]
        Resource = [
          "${module.well_known_s3_bucket.s3_bucket_arn}/*"
        ]
      },
      {
        Sid    = "CloudWatchDashboardPermission"
        Effect = "Allow"
        Action = [


          "cloudwatch:GetDashboard",

          "cloudwatch:ListDashboards",

          "cloudwatch:PutDashboard",

          "cloudwatch:DeleteDashboards"
        ]
        Resource = [
          "*"
        ]
      },
      {
        Sid    = "TimestreamActions"
        Effect = "Allow"
        Action = [
          "timestream:*"
        ]
        Resource = [
          aws_timestreamwrite_database.analytics_database.arn,
          "${aws_timestreamwrite_database.analytics_database.arn}/table/*"
        ]
      },
      {
        Sid    = "Timestream"
        Effect = "Allow"
        Action = [
          "timestream:DescribeEndpoints",
          "timestream:SelectValues",
          "timestream:CancelQuery"
        ]
        Resource = [

          "*"
        ]
      },
      {
        Sid    = "SQSeservicetelemetryresultqueue"
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:PurgeQueue"
        ]
        Resource = [

          "${module.sqs_registry_queue.queue_arn}",
          "${module.sqs_polling_queue.queue_arn}",
          "${module.sqs_polling_result_queue.queue_arn}",
          "${module.sqs_telemetry_result_queue.queue_arn}"
        ]
      },
      {
        Sid    = "KMSDecrypt"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Sign",
          "kms:Verify"
        ]
        Resource = [
          "${aws_kms_key.jwt_sign_key.arn}"
        ]
      },
      {
        Sid    = "XRayIntegration"
        Effect = "Allow"
        Action = [
          "xray:GetGroups",
          "xray:GetSamplingStatisticSummaries",
          "xray:PutTelemetryRecords",
          "xray:GetTraceGraph",
          "xray:GetServiceGraph",
          "xray:GetInsightImpactGraph",
          "xray:GetInsightSummaries",
          "xray:GetSamplingTargets",
          "xray:PutTraceSegments",
          "xray:CreateGroup",
          "xray:DeleteGroup",
          "xray:BatchGetTraces",
          "xray:BatchGetTraceSummaryById",
          "xray:GetTimeSeriesServiceStatistics",
          "xray:GetEncryptionConfig",
          "xray:GetSamplingRules",
          "xray:GetInsight",
          "xray:GetDistinctTraceGraphs",
          "xray:GetInsightEvents",
          "xray:GetTraceSummaries"
        ]

        Resource = [
          "*"
        ]
      }

    ]
  })
}

resource "aws_iam_group_policy" "uat" {
  count = var.env == "uat" ? 1 : 0

  name  = "UAT"
  group = aws_iam_group.external_developers[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Timestream"
        Effect = "Allow"
        Action = [
          "timestream:PrepareQuery",
          "timestream:Select",
          "timestream:SelectValues",
          "timestream:CancelQuery"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}
