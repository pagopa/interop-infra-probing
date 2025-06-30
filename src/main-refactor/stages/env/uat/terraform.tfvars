aws_region = "eu-south-1"
env        = "uat"
stage      = "uat"
azs        = ["eu-south-1a", "eu-south-1b", "eu-south-1c"]

tags = {
  Account     = "pdnd-probing-uat"
  Layer       = "stages"
  Stage       = "uat"
  CreatedBy   = "Terraform"
  Environment = "uat"
  Owner       = "PagoPA"
  Source      = "https://github.com/pagopa/interop-infra-probing"
}

sso_admin_role_name = "AWSReservedSSO_FullAdmin_4c15f6000e5b2a27"

interop_msk_cluster_arn = ""
