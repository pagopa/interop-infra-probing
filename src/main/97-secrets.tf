resource "aws_secretsmanager_secret" "aurora_master_user_credentials" {
  name = "/${var.app_name}/${var.env}/operational-database/master-user-credentials"
}

resource "aws_secretsmanager_secret_version" "aurora_master_user_credentials" {
  secret_id = aws_secretsmanager_secret.aurora_master_user_credentials.id
  secret_string = jsonencode({
    username = var.operational_database_name_master_user,
    password = module.aurora.cluster_master_password
  })
}

resource "aws_secretsmanager_secret" "be_probing_aurora_flyway_user_credentials" {
  name = "/${var.app_name}/${var.env}/operational-database/flyway-user-credentials"
}

resource "aws_secretsmanager_secret_version" "be_probing_aurora_flyway_user_credentials" {
  secret_id = aws_secretsmanager_secret.be_probing_aurora_flyway_user_credentials.id
  secret_string = jsonencode({
    username = "user",
    password = "password"
  })
}

resource "aws_secretsmanager_secret" "be_probing_app_aurora_user_credentials" {
  name = "/${var.app_name}/${var.env}/operational-database/app-user-credentials"
}

resource "aws_secretsmanager_secret_version" "be_probing_app_aurora_user_credentials" {
  secret_id = aws_secretsmanager_secret.be_probing_app_aurora_user_credentials.id
  secret_string = jsonencode({
    username = "user",
    password = "password"
  })
}
