data "aws_secretsmanager_secret_version" "be_probing_aurora_flyway_user_credentials" {
  secret_id     = "/${var.app_name}/${var.env}/operational-database/${var.be_prefix}-flyway-user-credentials"
  version_stage = "AWSCURRENT"
}

data "aws_secretsmanager_secret_version" "be_probing_aurora_api_user_credentials" {
  secret_id     = "/${var.app_name}/${var.env}/operational-database/${var.be_prefix}-interop-be-api-user-credentials"
  version_stage = "AWSCURRENT"
}