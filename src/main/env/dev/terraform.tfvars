aws_region = "eu-central-1"
env        = "dev"
app_name   = "interop-probing"

kubernetes_version = "1.24"

database_subnets = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
eks_control_plane_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
eks_workload_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

app_public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
tags = {
  CreatedBy   = "Terraform"
  Environment = "dev"
  Owner       = "PagoPA"
  Source      = "https://github.com/pagopa/interop-infra-probing"
}
