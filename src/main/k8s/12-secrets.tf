locals {
  aurora_flyway_user_credentials = jsondecode(data.aws_secretsmanager_secret_version.be_probing_aurora_flyway_user_credentials.secret_string)
  aurora_be_app_user_credentials = jsondecode(data.aws_secretsmanager_secret_version.be_probing_app_aurora_user_credentials.secret_string)
}

resource "kubernetes_secret_v1" "be_probing_aurora_flyway_user_credentials_secret_id" {
  metadata {
    name      = "${var.be_prefix}-aurora-flyway-user-credentials"
    namespace = kubernetes_namespace_v1.env.metadata[0].name
  }

  type = "Opaque"

  data = {
    FLYWAY_DATABASE_USERNAME = local.aurora_flyway_user_credentials.username
    FLYWAY_DATABASE_PASSWORD = local.aurora_flyway_user_credentials.password
  }
}

resource "kubernetes_secret_v1" "be_probing_aurora_app_user_credentials_secret_id" {
  metadata {
    name      = "${var.be_prefix}-app-aurora-user-credentials"
    namespace = kubernetes_namespace_v1.env.metadata[0].name
  }

  type = "Opaque"

  data = {
    DATABASE_USERNAME = local.aurora_be_app_user_credentials.username
    DATABASE_PASSWORD = local.aurora_be_app_user_credentials.password
  }
}

