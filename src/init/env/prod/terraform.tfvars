aws_region        = "eu-south-1"
env               = "prod"
github_repository = "pagopa/interop-infra-probing"

tags = {
  "CreatedBy"   = "Terraform"
  "Environment" = "prod"
  "Owner"       = "PagoPa"
  "Scope"       = "tfstate"
  "Source"      = "https://github.com/pagopa/interop-infra-probing"
  "name"        = "S3 Remote Terraform State Store"
}
