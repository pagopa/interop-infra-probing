resource "aws_cognito_user_pool" "user_pool" {
  name                = "${local.app_name}-user-pool-${var.stage}"
  deletion_protection = "ACTIVE"
  mfa_configuration   = "OFF"
  alias_attributes = [
    "email"
  ]

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true
    string_attribute_constraints {
      min_length = 4
      max_length = 2048
    }
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
  name = "${local.app_name}-fe-client-${var.stage}"

  user_pool_id    = aws_cognito_user_pool.user_pool.id
  generate_secret = false

  access_token_validity = var.stage == "qa" ? 24 : 1
  token_validity_units {
    access_token = "hours"
  }
}
