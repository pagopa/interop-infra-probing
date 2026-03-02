aws_region        = "eu-south-1"
env               = "uat"
github_repository = "pagopa/interop-infra-probing"

tags = {
  "CreatedBy"   = "Terraform"
  "Environment" = "uat"
  "Owner"       = "PagoPa"
  "Scope"       = "tfstate"
  "Source"      = "https://github.com/pagopa/interop-infra-probing"
  "name"        = "S3 Remote Terraform State Store"
}

