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

interop_msk_cluster_arn = "arn:aws:kafka:eu-south-1:505630707203:cluster/interop-platform-events-dev/259df37b-31c3-405c-bb30-d2bce2ca67c6-2"

dns_probing_base_domain = "stato-eservice.dev.interop.pagopa.it" #TOCHECK: is it correct? Or "dev.stato-eservice.interop.pagopa.it"
