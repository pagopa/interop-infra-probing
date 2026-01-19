aws_region = "eu-south-1"
env        = "prod"
azs        = ["eu-south-1a", "eu-south-1b", "eu-south-1c"]

stages_to_provision = ["prod"]

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
  "ns-1937.awsdns-50.co.uk.",
  "ns-1520.awsdns-62.org.",
  "ns-268.awsdns-33.com.",
  "ns-702.awsdns-23.net."
]

dns_probing_qa_ns_records = [
  "ns-1449.awsdns-53.org.",
  "ns-504.awsdns-63.com.",
  "ns-1728.awsdns-24.co.uk.",
  "ns-838.awsdns-40.net."
]

dns_probing_vapt_ns_records = []

dns_probing_uat_ns_records = []

dns_probing_att_ns_records = []
