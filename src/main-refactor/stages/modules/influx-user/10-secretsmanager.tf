resource "random_password" "this" {
  length  = var.generated_password_length
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "aws_secretsmanager_secret" "this" {
  name                    = "${var.secret_prefix}${var.username}"
  recovery_window_in_days = var.secret_recovery_window_in_days

  tags = var.secret_tags
}