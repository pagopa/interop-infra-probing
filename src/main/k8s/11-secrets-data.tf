data "aws_secretsmanager_secret_version" "be_probing_aurora_flyway_user_credentials" {
  secret_id     = "/${var.app_name}/${var.env}/operational-database/flyway-user-credentials"
  version_stage = "AWSCURRENT"
}

data "aws_secretsmanager_secret_version" "be_probing_app_aurora_user_credentials" {
  secret_id     = "/${var.app_name}/${var.env}/operational-database/app-user-credentials"
  version_stage = "AWSCURRENT"
}
