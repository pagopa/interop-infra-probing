resource "aws_kms_key" "jwt_sign" {
  description              = "KMS Key for signing JWT"
  customer_master_key_spec = "RSA_2048"
  key_usage                = "SIGN_VERIFY"
  enable_key_rotation      = false
  multi_region             = false
  deletion_window_in_days  = 30

  policy = jsonencode(
    {
      Id = "DefaultPolicy"
      Statement = [
        {
          Action = "kms:*"
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          }
          Resource = "*"
          Sid      = "EnableIAMPolicies"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_kms_alias" "jwt_sign_key" {
  name          = "alias/interop-probing-rsa2048-${var.stage}"
  target_key_id = aws_kms_key.jwt_sign.key_id
}
