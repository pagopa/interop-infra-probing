module "aurora" {
    source  = "terraform-aws-modules/rds-aurora/aws"

    name           = "${var.app_name}-operational-database-${var.env}"
    engine         = "aurora-postgresql"
    engine_version = "14.3"
    engine_mode = "serverless"
    instance_class = "db.serverless"


    create_db_subnet_group = true
    db_subnet_group_name = "${var.app_name}-aurora-${var.env}"

    vpc_id  = module.vpc.vpc_id
    subnets = [
        module.vpc.private_subnets[6],
        module.vpc.private_subnets[7],
        module.vpc.private_subnets[8]
    ]

    storage_encrypted   = true
    apply_immediately   = true
    monitoring_interval = 10


    enabled_cloudwatch_logs_exports = ["postgresql"]

    tags = {
    Environment = "dev"
    Terraform   = "true"
    }
    }