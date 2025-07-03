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
}

locals {
  cognito_users = {
    admins = {
      micheledellipaoli = {
        username = "micheledellipaoli"
        password = "Testmichele1!"
        attributes = {
          email          = "michele.dellipaoli@pagopa.it"
          email_verified = "true"
        }
        force_alias_creation = true
      }
    },
    users = {}
  }
}

resource "aws_cognito_user" "admins" {
  for_each = local.cognito_users.admins

  user_pool_id = aws_cognito_user_pool.user_pool.id
  username     = each.value.username
  password     = each.value.password != null ? each.value.password : null

  attributes = {
    for key, value in each.value.attributes : key => value
  }

  force_alias_creation = each.value.force_alias_creation
}

resource "aws_cognito_user_in_group" "admins" {
  for_each = aws_cognito_user.admins

  user_pool_id = aws_cognito_user_pool.user_pool.id
  group_name   = aws_cognito_user_group.admins.name
  username     = each.value.username
}

resource "aws_cognito_user" "users" {
  for_each = local.cognito_users.users

  user_pool_id = aws_cognito_user_pool.user_pool.id
  username     = each.value.username
  password     = each.value.password != null ? each.value.password : null

  attributes = {
    for key, value in each.value.attributes : key => value
  }

  force_alias_creation = each.value.force_alias_creation
}

resource "aws_cognito_user_in_group" "users" {
  for_each = aws_cognito_user.users

  user_pool_id = aws_cognito_user_pool.user_pool.id
  group_name   = aws_cognito_user_group.users.name
  username     = each.value.username
}