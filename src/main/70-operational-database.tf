module "aurora_postgresql_v2" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name              = "${var.app_name}-operational-database-${var.env}"
  engine            = "aurora-postgresql"
  engine_mode       = "provisioned"
  engine_version    = "14.6"
  storage_encrypted = true

  vpc_id                          = module.vpc.vpc_id
  subnets                         = module.vpc.database_subnets
  create_security_group           = true
  allowed_cidr_blocks             = module.vpc.private_subnets_cidr_blocks
  allowed_security_groups         = [aws_security_group.ssh_access.id]
  db_cluster_parameter_group_name = "${var.app_name}-operational-database-${var.env}"
  deletion_protection             = true

  monitoring_interval = 60

  apply_immediately   = false
  skip_final_snapshot = true

  serverlessv2_scaling_configuration = {
    min_capacity = var.database_min_capacity
    max_capacity = var.database_min_capacity
  }

  instance_class = "db.serverless"
  instances = {
    one = {}
    two = {}
  }
}