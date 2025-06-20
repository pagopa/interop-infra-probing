aws_region = "eu-south-1"
env        = "dev"
azs        = ["eu-south-1a", "eu-south-1b", "eu-south-1c"]

tags = {
  Account     = "pdnd-probing-dev"
  Layer       = "network"
  CreatedBy   = "Terraform"
  Environment = "dev"
  Owner       = "PagoPA"
  Source      = "https://github.com/pagopa/interop-infra-probing"
}

sso_admin_role_name = "AWSReservedSSO_FullAdmin_bd35c1497d9407bb"

dns_probing_base_domain = "dev.stato-eservice.interop.pagopa.it"
