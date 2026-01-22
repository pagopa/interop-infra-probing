locals {
  eks_secret_default_tags = {
    EKSClusterName                     = data.aws_eks_cluster.probing.name
    EKSClusterNamespacesSpaceSeparated = join(" ", [var.stage])
    TerraformState                     = local.terraform_state
  }
}

module "probing_operational_database_flyway_pgsql_user" {
  count = local.use_postgresql_user_module ? 1 : 0

  source = "git::https://github.com/pagopa/interop-infra-commons//terraform/modules/postgresql-user?ref=v1.22.0"

  username = "${var.stage}_probing_flyway_user"

  generated_password_length = 30
  secret_prefix             = format("rds/%s/users/", data.aws_rds_cluster.probing_operational_database.cluster_identifier)

  secret_tags = merge(local.eks_secret_default_tags,
    {
      EKSReplicaSecretName = "${var.stage}-probing-operational-db-flyway-user"
    }
  )

  db_host = data.aws_rds_cluster.probing_operational_database.endpoint
  db_port = data.aws_rds_cluster.probing_operational_database.port
  db_name = var.probing_operational_database_name

  db_admin_credentials_secret_arn = data.aws_rds_cluster.probing_operational_database.master_user_secret[0].secret_arn

  additional_sql_statements = <<-EOT
    GRANT CREATE ON DATABASE "${var.probing_operational_database_name}" TO ${var.stage}_probing_flyway_user;
  EOT
}

locals {
  be_app_psql_usernames = var.stage == "qa" ? [
    "eservice_operations_user",
    "user" # the final username will be qa_user
    ] : [
    "eservice_operations_user"
  ]
}


# PostgreSQL users with no initial grants. The grants will be applied by Flyway
module "probing_operational_database_be_app_pgsql_user" {
  depends_on = [module.probing_operational_database_flyway_pgsql_user]

  source = "git::https://github.com/pagopa/interop-infra-commons//terraform/modules/postgresql-user?ref=v1.22.0"

  for_each = local.use_postgresql_user_module ? toset(local.be_app_psql_usernames) : []

  username = format("%s_%s", var.stage, each.value)

  generated_password_length = 30
  secret_prefix             = format("rds/%s/users/", data.aws_rds_cluster.probing_operational_database.cluster_identifier)

  secret_tags = merge(local.eks_secret_default_tags,
    {
      EKSReplicaSecretName = format("%s-probing-operational-db-%s", var.stage, replace(each.value, "_", "-"))
    }
  )

  db_host = data.aws_rds_cluster.probing_operational_database.endpoint
  db_port = data.aws_rds_cluster.probing_operational_database.port
  db_name = var.probing_operational_database_name

  db_admin_credentials_secret_arn = data.aws_rds_cluster.probing_operational_database.master_user_secret[0].secret_arn
}
