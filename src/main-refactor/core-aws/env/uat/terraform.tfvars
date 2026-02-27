aws_region = "eu-south-1"
env        = "uat"
azs        = ["eu-south-1a", "eu-south-1b", "eu-south-1c"]

stages_to_provision = ["uat", "att"]

tags = {
  Account     = "pdnd-probing-uat"
  Layer       = "core"
  CreatedBy   = "Terraform"
  Environment = "uat"
  Owner       = "PagoPA"
  Source      = "https://github.com/pagopa/interop-infra-probing"
}

sso_admin_role_name = "AWSReservedSSO_FullAdmin_4c15f6000e5b2a27"

vpc_id                  = "vpc-0acbd5bcdb93a591d"
eks_workload_cidrs      = ["10.0.0.0/21", "10.0.8.0/21", "10.0.16.0/21"]
eks_control_plane_cidrs = ["10.0.24.0/24", "10.0.25.0/24", "10.0.26.0/24"]
aurora_cidrs            = ["10.0.30.0/24", "10.0.31.0/24", "10.0.32.0/24"]
msk_cidrs               = ["10.0.42.0/24", "10.0.43.0/24", "10.0.44.0/24"]
timestream_cidrs        = ["10.0.45.0/24", "10.0.46.0/24", "10.0.47.0/24"]

vpn_clients_security_group_id = "sg-07c2290ada626b422"

interop_msk_clusters_arns = {
  test = "arn:aws:kafka:eu-south-1:895646477129:cluster/interop-platform-events-test/2952348f-d39d-47b2-925c-bd3edc78000c-3",
  att  = "arn:aws:kafka:eu-south-1:533267098416:cluster/interop-platform-events-att/ab17674c-f6d6-4a0b-a844-faab53eee76e-3"
}

probing_analytics_database_name = "interop_probing_telemetry"

probing_operational_database_prefix_name        = "interop_probing_operational"
probing_operational_database_master_username    = "root"
probing_operational_database_engine_version     = "16.8"
probing_operational_database_instance_class     = "db.t4g.medium"
probing_operational_database_number_instances   = 3
probing_operational_database_ca_cert_id         = "rds-ca-rsa2048-g1"
probing_operational_database_param_group_family = "aurora-postgresql16"

eks_k8s_version = "1.32"

backend_microservices_port = 8080

project_monorepo_name = "pagopa/interop-probing-core"

github_runners_allowed_repos = ["pagopa/interop-probing-deployment"]
github_runners_cpu           = 2048
github_runners_memory        = 4096
github_runners_image_uri     = "ghcr.io/pagopa/interop-github-runner-aws:v1.20.0"

deployment_repo_name = "pagopa/interop-probing-deployment"
