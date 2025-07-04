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

dns_probing_dev_ns_records = [
  "ns-790.awsdns-34.net.",
  "ns-1703.awsdns-20.co.uk.",
  "ns-1145.awsdns-15.org.",
  "ns-323.awsdns-40.com."
]

dns_probing_qa_ns_records = []

dns_probing_vapt_ns_records = []

dns_probing_uat_ns_records = []

dns_probing_att_ns_records = []
