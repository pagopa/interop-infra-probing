# resource "random_password" "this" {
#   length  = var.generated_password_length
#   special = false
#   upper   = true
#   lower   = true
#   numeric = true
# }

data "aws_secretsmanager_random_password" "this" {
  password_length            = var.generated_password_length
  require_each_included_type = true
  exclude_punctuation        = true
}

resource "aws_secretsmanager_secret" "this" {
  name                    = "${var.secret_prefix}${var.username}"
  recovery_window_in_days = var.secret_recovery_window_in_days

  tags = var.secret_tags
}