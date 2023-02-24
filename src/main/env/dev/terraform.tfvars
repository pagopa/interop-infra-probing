aws_region = "eu-central-1"
env        = "dev"
app_name   = "interop-probing"

kubernetes_version = "1.24"

database_subnets = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
eks_control_plane_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
eks_workload_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

app_public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

bastion_host_ami = "amzn2-ami-kernel-5.10-hvm-2.0.20230207.0-x86_64-gp2"
bastion_host_instance_type = "t3.micro"
bastion_host_key_pair_name = "interop-probing-bh-dev"

operational_database_name = "interop_probing_operational"
operational_database_name_master_user = "root"

database_scaling_min_capacity = 2
database_scaling_max_capacity = 10
tags = {
  CreatedBy   = "Terraform"
  Environment = "dev"
  Owner       = "PagoPA"
  Source      = "https://github.com/pagopa/interop-infra-probing"
}
