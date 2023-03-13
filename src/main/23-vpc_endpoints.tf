resource "aws_security_group" "sqs_endpoint" {
  name        = "${var.app_name}-sqs-vpce-sg-${var.env}"
  description = "Security group for SQS VPC Endpoint"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "TLS from VPC"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [module.eks.cluster_security_group_id, aws_security_group.bastion_host_ssh_access.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

module "timestream_ingest_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "timestream-ingest"
  description = "Security group for timestream ingest VPC Endpoint"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "https-443-tcp"
      source_security_group_id = module.eks.cluster_security_group_id
    },
  ]
  ingress_rules = ["https-443-tcp"]

}


module "timestream_query_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "timestream-query"
  description = "Security group for timestream query VPC Endpoint"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "https-443-tcp"
      source_security_group_id = module.eks.cluster_security_group_id
    },
  ]
  ingress_rules = ["https-443-tcp"]

}

module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.eks.cluster_security_group_id]

  endpoints = {
    s3 = {
      # interface endpoint
      service = "s3"
    },
    sqs = {
      service             = "sqs"
      private_dns_enabled = true
      security_group_ids  = [aws_security_group.sqs_endpoint.id]
      subnet_ids          = data.aws_subnets.workload.ids
    },
    timestream_ingest = {
      service_name        = "com.amazonaws.${var.aws_region}.timestream.ingest-cell1"
      private_dns_enabled = true
      security_group_ids  = [module.timestream_ingest_sg.security_group_id]
      subnet_ids          = data.aws_subnets.workload.ids
    },
    timestream_query = {
      service_name        = "com.amazonaws.${var.aws_region}.timestream.query-cell1"
      private_dns_enabled = true
      security_group_ids  = [module.timestream_query_sg.security_group_id]
      subnet_ids          = data.aws_subnets.workload.ids
    }
  }

}
