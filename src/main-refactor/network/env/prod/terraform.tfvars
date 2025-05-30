aws_region = "eu-south-1"
env        = "prod"
azs        = ["eu-south-1a", "eu-south-1b", "eu-south-1c"]

tags = {
  Account     = "pdnd-probing-prod"
  Layer       = "network"
  CreatedBy   = "Terraform"
  Environment = "prod"
  Owner       = "PagoPA"
  Source      = "https://github.com/pagopa/interop-infra-probing"
}

sso_admin_role_name = "AWSReservedSSO_FullAdmin_"

interop_msk_cluster_arn = ""

dns_probing_base_domain = "stato-eservice.interop.pagopa.it"

dns_tracing_dev_ns_records = []

dns_tracing_qa_ns_records = []

dns_tracing_vapt_ns_records = []

dns_tracing_uat_ns_records = []

dns_tracing_att_ns_records = []