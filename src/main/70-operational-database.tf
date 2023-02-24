module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "7.6.2"

  name              = "${var.app_name}-operational-database-${var.env}"
  engine            = "aurora-postgresql"
  engine_mode       = "provisioned"
  engine_version    = data.aws_rds_engine_version.postgresql.version
  storage_encrypted = true

  vpc_id                  = module.vpc.vpc_id
  subnets                 = module.vpc.database_subnets
  create_security_group   = true
  allowed_security_groups = [aws_security_group.bastion_host_ssh_access.id]
  master_username         = var.operational_database_name_master_user
  deletion_protection     = true
  database_name           = var.operational_database_name

  create_db_parameter_group         = true
  create_db_cluster_parameter_group = true
  db_parameter_group_name           = "${var.app_name}-aurora-db-postgres14-parameter-group-${var.env}"
  db_cluster_parameter_group_name   = "${var.app_name}-aurora-postgres14-cluster-parameter-group-${var.env}"
  apply_immediately                 = true
  skip_final_snapshot               = false

  serverlessv2_scaling_configuration = {
    min_capacity = var.database_scaling_min_capacity
    max_capacity = var.database_scaling_max_capacity
  }

  instance_class = "db.serverless"
  instances = {
    one = {}
    two = {}
  }
}

data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "14.6"
}

resource "aws_secretsmanager_secret" "database_aurora_master_password" {
  name = "/${var.app_name}/${var.env}/operational-database/master_password"
}

resource "aws_secretsmanager_secret_version" "database_aurora_master_password" {
  secret_id = aws_secretsmanager_secret.database_aurora_master_password.id
  secret_string = jsonencode({
    master_username = var.operational_database_name_master_user,
    master_password = module.aurora.cluster_master_password
  })
}

