data "aws_subnets" "vpce" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }

  filter {
    name   = "cidr-block"
    values = toset(local.vpce_cidrs)
  }
}

data "aws_route_tables" "vpce" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }
}

#TO RESTRICT?
resource "aws_security_group" "vpce_common" {
  name        = format("vpce/%s-vpce-common-%s", local.project, var.env)
  description = "Common SG across all VPC Endpoints"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
}

module "vpce_gateway" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.8.1"

  vpc_id = module.vpc.vpc_id

  endpoints = {
    s3 = {
      service_name    = "com.amazonaws.${var.aws_region}.s3"
      service_type    = "Gateway"
      route_table_ids = data.aws_route_tables.vpce.ids

      tags = { Name = "S3" }
    }
  }
}

module "vpce_interface" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.8.1"

  vpc_id = module.vpc.vpc_id
  # Create one VPCE per AZ only in prod
  subnet_ids         = var.env == "prod" ? data.aws_subnets.vpce.ids : [data.aws_subnets.vpce.ids[0]]
  security_group_ids = [aws_security_group.vpce_common.id]

  endpoints = {
    secrets_manager = {
      service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
      service_type        = "Interface"
      private_dns_enabled = true

      tags = { Name = "SecretsManager" }
    },
    kms = {
      service_name        = "com.amazonaws.${var.aws_region}.kms"
      service_type        = "Interface"
      private_dns_enabled = true

      tags = { Name = "KMS" }
    },
    dkr_ecr = {
      service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
      service_type        = "Interface"
      private_dns_enabled = true

      tags = { Name = "ECR-DKR" }
    },
    api_ecr = {
      service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
      service_type        = "Interface"
      private_dns_enabled = true

      tags = { Name = "ECR-API" }
    },
    sqs = {
      service_name        = "com.amazonaws.${var.aws_region}.sqs"
      service_type        = "Interface"
      private_dns_enabled = true

      tags = { Name = "SQS" }
    },
    cloudwatch_monitoring = {
      service_name        = "com.amazonaws.${var.aws_region}.monitoring"
      service_type        = "Interface"
      private_dns_enabled = true

      tags = { Name = "CloudWatch-Monitoring" }
    },
    cloudwatch_logs = {
      service_name        = "com.amazonaws.${var.aws_region}.logs"
      service_type        = "Interface"
      private_dns_enabled = true

      tags = { Name = "CloudWatch-Logs" }
    }
  }
}