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

  username = "probing_operational_db_flyway_user_${var.stage}"

  generated_password_length = 30
  secret_prefix             = format("rds/%s/users/", data.aws_rds_cluster.probing_operational_database.cluster_identifier)

  secret_tags = merge(local.eks_secret_default_tags,
    {
      EKSReplicaSecretName = "probing-operational-db-flyway-user-${var.stage}"
    }
  )

  db_host = data.aws_rds_cluster.probing_operational_database.endpoint
  db_port = data.aws_rds_cluster.probing_operational_database.port
  db_name = var.probing_operational_database_name

  db_admin_credentials_secret_arn = data.aws_rds_cluster.probing_operational_database.master_user_secret[0].secret_arn

  additional_sql_statements = <<-EOT
    GRANT CREATE ON DATABASE "${var.probing_operational_database_name}" TO probing_operational_db_flyway_user_${var.stage};
  EOT
}

locals {
  be_app_psql_usernames = local.use_postgresql_user_module ? {
    eservice_operations_user = {
      sql_name        = "probing_eservice_operations_user_${var.stage}",
      k8s_secret_name = "probing-operational-db-eservice-operations-user-${var.stage}"
    }
  } : {}
}

# PostgreSQL users with no initial grants. The grants will be applied by Flyway
module "probing_operational_database_be_app_pgsql_user" {
  source = "git::https://github.com/pagopa/interop-infra-commons//terraform/modules/postgresql-user?ref=v1.22.0"

  for_each = local.be_app_psql_usernames

  username = each.value.sql_name

  generated_password_length = 30
  secret_prefix             = format("rds/%s/users/", data.aws_rds_cluster.probing_operational_database.cluster_identifier)

  secret_tags = merge(local.eks_secret_default_tags,
    {
      EKSReplicaSecretName = each.value.k8s_secret_name
    }
  )

  db_host = data.aws_rds_cluster.probing_operational_database.endpoint
  db_port = data.aws_rds_cluster.probing_operational_database.port
  db_name = var.probing_operational_database_name

  db_admin_credentials_secret_arn = data.aws_rds_cluster.probing_operational_database.master_user_secret[0].secret_arn
}
