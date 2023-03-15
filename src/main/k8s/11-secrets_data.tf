data "aws_secretsmanager_secret_version" "aurora_flyway_user_credentials" {
  secret_id     = "/${var.app_name}/${var.env}/operational-database/flyway_user_credentials"
  version_stage = "AWSCURRENT"
}

data "aws_secretsmanager_secret_version" "aurora_interop_be_api_user_credentials" {
  secret_id     = "/${var.app_name}/${var.env}/operational-database/interop_be_api_user_credentials"
  version_stage = "AWSCURRENT"
}