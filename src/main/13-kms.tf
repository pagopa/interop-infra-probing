resource "aws_kms_key" "jwt_sign_key" {
  description              = "KMS Key for signing JWT"
  key_usage                = "SIGN_VERIFY"
  customer_master_key_spec = "RSA_2048"
  enable_key_rotation      = false
  multi_region             = false
  deletion_window_in_days  = 30
}