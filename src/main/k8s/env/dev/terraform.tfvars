aws_region = "eu-central-1"
env        = "dev"
app_name   = "interop-probing"

tags = {
  CreatedBy   = "Terraform"
  Environment = "dev"
  Owner       = "PagoPA"
  Source      = "https://github.com/pagopa/interop-infra-probing"
}

eks_cluster_name         = "interop-probing-eks-dev"
sso_full_admin_role_name = "AWSReservedSSO_FullAdmin_43e33324db7f1652"
