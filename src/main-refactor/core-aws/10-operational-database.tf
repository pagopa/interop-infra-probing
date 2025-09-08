resource "aws_kms_key" "probing_operational_database" {
  description              = format("rds/%s-store-%s", local.project, var.env)
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
}

module "probing_operational_database" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "9.3.1"

  name = format("%s-store-%s", local.project, var.env)

  deletion_protection        = true
  apply_immediately          = var.env != "prod"
  auto_minor_version_upgrade = false

  database_name                        = format("%s_%s", var.probing_operational_database_prefix_name, var.env)
  master_username                      = var.probing_operational_database_master_username
  manage_master_user_password          = true
  manage_master_user_password_rotation = false

  engine             = "aurora-postgresql"
  engine_version     = var.probing_operational_database_engine_version
  instance_class     = var.probing_operational_database_instance_class
  ca_cert_identifier = var.probing_operational_database_ca_cert_id

  instances_use_identifier_prefix = false
  instances = { for i in range(var.probing_operational_database_number_instances) :
    "instance-${i + 1}" => {
      identifier        = "probing-operational-database-${i + 1}"
      availability_zone = element(var.azs, i)
    }
  }

  create_db_cluster_parameter_group          = true
  db_cluster_parameter_group_use_name_prefix = false
  db_cluster_parameter_group_name            = format("%s-store-%s", local.project, var.env)
  db_cluster_parameter_group_family          = var.probing_operational_database_param_group_family

  db_cluster_parameter_group_parameters = [
    {
      name  = "rds.force_ssl"
      value = 1
    }
  ]

  vpc_id             = data.aws_vpc.probing.id
  subnets            = data.aws_subnets.aurora_probing_operational_store.ids
  availability_zones = var.azs

  create_db_subnet_group = true
  db_subnet_group_name   = format("%s-store-%s", local.project, var.env)

  create_security_group          = true
  security_group_use_name_prefix = false
  security_group_name            = format("rds/%s-store-%s", local.project, var.env)

  security_group_rules = {
    from_eks_cluster = {
      type                     = "ingress"
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = module.eks.cluster_primary_security_group_id
      description              = "From EKS cluster"
    }

    vpn_clients = {
      type                     = "ingress"
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = data.aws_security_group.vpn_clients.id
      description              = "From VPN clients"
    }
  }

  storage_encrypted       = true
  kms_key_id              = aws_kms_key.probing_operational_database.arn
  backup_retention_period = var.env == "prod" ? 90 : 7
  skip_final_snapshot     = false

  create_cloudwatch_log_group            = true
  enabled_cloudwatch_logs_exports        = ["postgresql"]
  cloudwatch_log_group_retention_in_days = var.env == "prod" ? 180 : 30

  create_monitoring_role                = true
  iam_role_name                         = format("%s-store-enhanced-monitoring-%s", local.project, var.env)
  performance_insights_enabled          = true
  performance_insights_retention_period = var.env == "prod" ? 372 : 7
  monitoring_interval                   = 60
  performance_insights_kms_key_id       = aws_kms_key.probing_operational_database.arn
}

locals {
  databases_to_create = [
    for stage in var.stages_to_provision : format("%s_%s", var.probing_operational_database_prefix_name, stage) if stage != var.env # Exclude the current environment from the list of databases to create
  ]
}

# Create a database for each stage (excluding the one equals to the var.env value because it is already created by the rds-aurora module)
resource "null_resource" "probing_operational_database_create_db" {
  depends_on = [module.probing_operational_database]

  for_each = toset(local.databases_to_create)

  provisioner "local-exec" {
    environment = {
      HOST                         = module.probing_operational_database.cluster_endpoint
      DATABASE                     = module.probing_operational_database.cluster_database_name
      DATABASE_PORT                = module.probing_operational_database.cluster_port
      DATABASE_TO_CREATE           = each.key
      ADMIN_CREDENTIALS_SECRET_ARN = module.probing_operational_database.cluster_master_user_secret[0].secret_arn
    }

    command = <<EOT
      #!/bin/bash
      set -euo pipefail
      
      secret_json=$(aws secretsmanager get-secret-value --secret-id $ADMIN_CREDENTIALS_SECRET_ARN --query SecretString --output text)

      ADMIN_USERNAME=$(echo $secret_json | jq -r '.username')
      ADMIN_PASSWORD=$(echo $secret_json | jq -r '.password')

      export PGPASSWORD=$ADMIN_PASSWORD

      DB_EXISTS=$(psql --host "$HOST" --username "$ADMIN_USERNAME" --port "$DATABASE_PORT" --dbname "$DATABASE" -tAc "SELECT 1 FROM pg_database WHERE datname = '$DATABASE_TO_CREATE';")

      if [ "$DB_EXISTS" != "1" ]; then
        echo "Creating database '$DATABASE_TO_CREATE'..."
        psql --host "$HOST" --username "$ADMIN_USERNAME" --port "$DATABASE_PORT" --dbname "$DATABASE" -c "CREATE DATABASE '$DATABASE_TO_CREATE';"
      else
        echo "Database '$DATABASE_TO_CREATE' already exists."
      fi
    EOT
  }
}