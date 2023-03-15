
locals {
  aurora_flyway_user_credentials         = jsondecode(data.aws_secretsmanager_secret_version.aurora_flyway_user_credentials.secret_string)
  aurora_interop_be_api_user_credentials = jsondecode(data.aws_secretsmanager_secret_version.aurora_interop_be_api_user_credentials.secret_string)
}

resource "kubernetes_secret_v1" "aurora_flyway_user_credentials_secret_id" {
  metadata {
    name = "aurora-flyway-user-credentials"
  }

  type = "Opaque"

  data = {
    FLYWAY_DATABASE_USERNAME = local.aurora_flyway_user_credentials.username
    FLYWAY_DATABASE_PASSWORD = local.aurora_flyway_user_credentials.password
  }
}

resource "kubernetes_secret_v1" "aurora_interop_be_api_user_credentials_secret_id" {
  metadata {
    name = "aurora-interop-be-api-user-credentials"
  }
  type = "Opaque"

  data = {
    DATABASE_USERNAME = local.aurora_interop_be_api_user_credentials.username
    DATABASE_PASSWORD = local.aurora_interop_be_api_user_credentials.password
  }
}