resource "aws_vpc_endpoint" "sqs" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.sqs"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    module.vpc.default_security_group_id,
  ]

  private_dns_enabled = true
}