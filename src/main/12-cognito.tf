data "local_file" "verification_message_template" {
  filename = "${path.module}/assets/email_templates/resetPassword.html"
}
resource "aws_cognito_user_pool" "user_pool" {
  name                = "${var.app_name}-user-pool-${var.env}"
  deletion_protection = "ACTIVE"
  mfa_configuration   = "OFF"

  verification_message_template {
    email_subject = "Ripristino password"
    email_message = data.local_file.verification_message_template.content
  }

  lambda_config {
    custom_message = aws_lambda_function.cognito_messaging.arn
  }
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }
}

resource "aws_cognito_user_group" "admins" {
  name         = "admins"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

resource "aws_cognito_user_group" "users" {
  name         = "users"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

resource "aws_cognito_user_pool_client" "client" {
  name = "${var.app_name}-fe-client-${var.env}"

  user_pool_id    = aws_cognito_user_pool.user_pool.id
  generate_secret = false
}
