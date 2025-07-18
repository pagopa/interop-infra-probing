aws_region = "eu-south-1"
env        = "prod"
stage      = "prod"
azs        = ["eu-south-1a", "eu-south-1b", "eu-south-1c"]

tags = {
  Account     = "pdnd-probing-prod"
  Layer       = "stages"
  Stage       = "prod"
  CreatedBy   = "Terraform"
  Environment = "prod"
  Owner       = "PagoPA"
  Source      = "https://github.com/pagopa/interop-infra-probing"
}

sso_admin_role_name = "AWSReservedSSO_FullAdmin_bd35c1497d9407bb"

interop_msk_cluster_arn = ""
