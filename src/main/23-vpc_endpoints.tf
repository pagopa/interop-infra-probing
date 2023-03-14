resource "aws_security_group" "sqs_endpoint" {
  name        = "${var.app_name}-sqs-vpce-sg-${var.env}"
  description = "Security group for SQS VPC Endpoint"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "TLS from VPC"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [module.eks.cluster_primary_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "timestream_ingest_sg" {
  name        = "${var.app_name}-timestream_ingest-sg-${var.env}"
  description = "Security group for Timestream ingest VPC Endpoint"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "TLS from VPC"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [module.eks.cluster_primary_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "timestream_query_sg" {
  name        = "${var.app_name}-timestream_query-vpce-sg-${var.env}"
  description = "Security group for Timestream Query VPC Endpoint"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "TLS from VPC"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [module.eks.cluster_primary_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.eks.cluster_primary_security_group_id]

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
      security_group_ids  = [aws_security_group.timestream_ingest_sg.id]
      subnet_ids          = data.aws_subnets.workload.ids
    },
    timestream_query = {
      service_name        = "com.amazonaws.${var.aws_region}.timestream.query-cell1"
      private_dns_enabled = true
      security_group_ids  = [aws_security_group.timestream_query_sg.id]
      subnet_ids          = data.aws_subnets.workload.ids
    }
  }

}
