module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.vpc.default_security_group_id]

  endpoints = {
    s3 = {
      # interface endpoint
      service = "s3"
    },
    sqs = {
      service             = "sqs"
      private_dns_enabled = true
      security_group_ids  = [module.vpc.default_security_group_id]
    }
  }

}

#SEPARATE BECAUSE NOT FOUND WITH MODULE
resource "aws_vpc_endpoint" "timestream_ingest" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.timestream.ingest-cell1"
  vpc_endpoint_type = "Interface"

  security_group_ids = [module.vpc.default_security_group_id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "timestream_query" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.timestream.query-cell-1"
  vpc_endpoint_type = "Interface"

  security_group_ids = [module.vpc.default_security_group_id]

  private_dns_enabled = true
}

