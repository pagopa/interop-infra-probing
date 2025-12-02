aws_region = "eu-south-1"
env        = "dev"
azs        = ["eu-south-1a", "eu-south-1b", "eu-south-1c"]

stages_to_provision = ["dev", "qa", "vapt"]

tags = {
  Account     = "pdnd-probing-dev"
  Layer       = "core"
  CreatedBy   = "Terraform"
  Environment = "dev"
  Owner       = "PagoPA"
  Source      = "https://github.com/pagopa/interop-infra-probing"
}

sso_admin_role_name = "AWSReservedSSO_FullAdmin_bd35c1497d9407bb"

vpc_id                  = "vpc-0e2fb2d5964ac4d11"
eks_workload_cidrs      = ["10.0.0.0/21", "10.0.8.0/21", "10.0.16.0/21"]
eks_control_plane_cidrs = ["10.0.24.0/24", "10.0.25.0/24", "10.0.26.0/24"]
aurora_cidrs            = ["10.0.30.0/24", "10.0.31.0/24", "10.0.32.0/24"]
msk_cidrs               = ["10.0.42.0/24", "10.0.43.0/24", "10.0.44.0/24"]
timestream_cidrs        = ["10.0.45.0/24", "10.0.46.0/24", "10.0.47.0/24"]

vpn_clients_security_group_id = "sg-0c8f3d10d3335676c"

interop_msk_clusters_arns = {
  dev = "arn:aws:kafka:eu-south-1:505630707203:cluster/interop-platform-events-dev/259df37b-31c3-405c-bb30-d2bce2ca67c6-2"
}

probing_analytics_database_name = "interop_probing_telemetry"

probing_operational_database_prefix_name        = "interop_probing_operational"
probing_operational_database_master_username    = "root"
probing_operational_database_engine_version     = "16.1"
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
github_runners_image_uri     = "ghcr.io/pagopa/interop-github-runner-aws:v1.19.2"

deployment_repo_name = "pagopa/interop-probing-deployment"
