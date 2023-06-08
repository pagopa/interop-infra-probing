resource "aws_cognito_user_pool" "user_pool" {
  name                = "${var.app_name}-user-pool-${var.env}"
  deletion_protection = "ACTIVE"
  mfa_configuration   = "OFF"

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
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_message        = "{####} Insert html"
    email_subject        = "Confirmation subject"
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
