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
  name = "ExternalDevelopers"
  path = "/externals/"
}

resource "aws_iam_group_policy_attachment" "read_only" {
  group      = aws_iam_group.external_developers.name
  policy_arn = data.aws_iam_policy.read_only.arn
}

resource "aws_iam_group_policy_attachment" "iam_user_password" {
  group      = aws_iam_group.external_developers.name
  policy_arn = data.aws_iam_policy.iam_user_password.arn
}

resource "aws_iam_group_policy_attachment" "secrets_manager_read_write" {
  group      = aws_iam_group.external_developers.name
  policy_arn = data.aws_iam_policy.secrets_manager_read_write.arn
}

resource "aws_iam_group_policy_attachment" "user_mfa" {
  group      = aws_iam_group.external_developers.name
  policy_arn = aws_iam_policy.user_mfa.arn
}

resource "aws_iam_group_policy" "terraform_lock" {
  name  = "TerraformLock"
  group = aws_iam_group.external_developers.name

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
