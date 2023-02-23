module "aurora" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name              = "${var.app_name}-operational-database-${var.env}"
  engine            = "aurora-postgresql"
  engine_version    = "14.6"
  engine_mode       = "serverless"
  instance_class    = "db.serverless"
  storage_encrypted = true

  create_db_subnet_group = true
  db_subnet_group_name   = "${var.app_name}-aurora-${var.env}"

  vpc_id                          = module.vpc.vpc_id
  subnets                         = module.vpc.database_subnets
  create_security_group           = true
  allowed_security_groups         = [aws_security_group.bastion_host_ssh_access.id]
  db_cluster_parameter_group_name = "${var.app_name}-operational-database-${var.env}"
  master_username                 = "root"
  deletion_protection             = true
  database_name                   = var.operational_database_name
  apply_immediately               = true
  skip_final_snapshot             = false

  scaling_configuration = {
    min_capacity = var.database_scaling_min_capacity
    max_capacity = var.database_scaling_max_capacity
  }

}

resource "aws_secretsmanager_secret" "database_aurora_master_password" {
  name = "/${var.app_name}/${var.env}/operational-database/master_password"
}

resource "aws_secretsmanager_secret_version" "database_aurora_master_password" {
  secret_id = aws_secretsmanager_secret.database_aurora_master_password.id
  secret_string = jsonencode({
    master_password = module.aurora.cluster_master_password
  })
}