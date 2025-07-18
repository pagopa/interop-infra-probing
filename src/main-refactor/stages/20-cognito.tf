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
  cognito_users_json_data = jsondecode(file("./assets/cognito-users/cognito-users-${var.stage}.json"))

  cognito_admins = try([
    for admin in local.cognito_users_json_data.admins : {
      username = admin.username
      email    = admin.email
    }
  ], [])

  cognito_users = try([
    for user in local.cognito_users_json_data.users : {
      username = user.username
      email    = user.email
    }
  ], [])
}

resource "random_password" "admins" {
  for_each = { for admin in local.cognito_admins : "${admin.username}" => admin }

  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

resource "aws_cognito_user" "admins" {
  depends_on = [random_password.admins]

  for_each = { for admin in local.cognito_admins : "${admin.username}" => admin }

  user_pool_id = aws_cognito_user_pool.user_pool.id
  username     = each.value.username
  password     = random_password.admins[each.key].result

  attributes = {
    email          = each.value.email
    email_verified = true
  }

  force_alias_creation = true
}

resource "aws_cognito_user_in_group" "admins" {
  for_each = aws_cognito_user.admins

  user_pool_id = aws_cognito_user_pool.user_pool.id
  group_name   = aws_cognito_user_group.admins.name
  username     = each.value.username
}

resource "random_password" "users" {
  for_each = { for user in local.cognito_users : "${user.username}" => user }

  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

resource "aws_cognito_user" "users" {
  depends_on = [random_password.users]

  for_each = { for user in local.cognito_users : "${user.username}" => user }

  user_pool_id = aws_cognito_user_pool.user_pool.id
  username     = each.value.username
  password     = random_password.users[each.key].result

  attributes = {
    email          = each.value.email
    email_verified = true
  }

  force_alias_creation = true
}

resource "aws_cognito_user_in_group" "users" {
  for_each = aws_cognito_user.users

  user_pool_id = aws_cognito_user_pool.user_pool.id
  group_name   = aws_cognito_user_group.users.name
  username     = each.value.username
}