resource "aws_secretsmanager_secret" "be_probing_aurora_master_user_credentials" {
  name = "/${var.app_name}/${var.env}/operational-database/${var.be_prefix}-master-user-credentials"
}

resource "aws_secretsmanager_secret_version" "be_probing_aurora_master_user_credentials" {
  secret_id = aws_secretsmanager_secret.be_probing_aurora_master_user_credentials.id
  secret_string = jsonencode({
    username = var.operational_database_name_master_user,
    password = module.aurora.cluster_master_password
  })
}

resource "aws_secretsmanager_secret" "be_probing_aurora_flyway_user_credentials" {
  name = "/${var.app_name}/${var.env}/operational-database/${var.be_prefix}-flyway-user-credentials"
}

resource "aws_secretsmanager_secret_version" "be_probing_aurora_flyway_user_credentials" {
  secret_id = aws_secretsmanager_secret.be_probing_aurora_flyway_user_credentials.id
  secret_string = jsonencode({
    username = "user",
    password = "password"
  })
}

resource "aws_secretsmanager_secret" "be_probing_aurora_api_user_credentials" {
  name = "/${var.app_name}/${var.env}/operational-database/${var.be_prefix}-interop-be-api-user-credentials"
}

resource "aws_secretsmanager_secret_version" "be_probing_aurora_api_user_credentials" {
  secret_id = aws_secretsmanager_secret.be_probing_aurora_api_user_credentials.id
  secret_string = jsonencode({
    username = "user",
    password = "password"
  })
}