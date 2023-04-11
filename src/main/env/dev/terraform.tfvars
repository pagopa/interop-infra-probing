aws_region          = "eu-central-1"
env                 = "dev"
app_name            = "interop-probing"
be_prefix           = "interop-be-probing"
sso_admin_role_name = "AWSReservedSSO_FullAdmin_43e33324db7f1652"

kubernetes_version = "1.24"
kubernetes_addons_versions = {
  kube-proxy = "v1.24.9-eksbuild.1"
  vpc-cni    = "v1.12.2-eksbuild.1"
  coredns    = "v1.9.3-eksbuild.2"
}

interop_probing_bucket_arn = "arn:aws:s3:::interop-probing-eservices-dev"

database_subnets          = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
eks_control_plane_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
eks_workload_subnets      = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

app_public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

bastion_host_ami           = "amzn2-ami-kernel-5.10-hvm-2.0.20230207.0-x86_64-gp2"
bastion_host_instance_type = "t3.micro"
bastion_host_key_pair_name = "interop-probing-bh-dev"

operational_database_name             = "interop_probing_operational"
operational_database_name_master_user = "root"

analytics_database_name = "interop_probing_telemetry"

database_scaling_min_capacity = 2
database_scaling_max_capacity = 10

alb_ingress_group = "interop-probing-alb"
api_version       = "v1"

openapi_spec_path     = "./assets/openapi_spec/interop-probing-dev-api-v1.yaml"
tags = {
  CreatedBy   = "Terraform"
  Environment = "dev"
  Owner       = "PagoPA"
  Source      = "https://github.com/pagopa/interop-infra-probing"
}
