aws_region = "eu-south-1"
env        = "uat"
azs        = ["eu-south-1a", "eu-south-1b", "eu-south-1c"]

tags = {
  Account     = "pdnd-probing-uat"
  Layer       = "network"
  CreatedBy   = "Terraform"
  Environment = "uat"
  Owner       = "PagoPA"
  Source      = "https://github.com/pagopa/interop-infra-probing"
}

sso_admin_role_name = "AWSReservedSSO_FullAdmin_4c15f6000e5b2a27"

interop_msk_cluster_arn = ""

dns_probing_base_domain = "stato-eservice.uat.interop.pagopa.it" #TOCHECK: is it correct? Or "uat.stato-eservice.interop.pagopa.it"