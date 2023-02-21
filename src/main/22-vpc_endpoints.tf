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