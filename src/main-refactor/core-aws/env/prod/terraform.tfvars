aws_region = "eu-south-1"
env        = "prod"
azs        = ["eu-south-1a", "eu-south-1b", "eu-south-1c"]

stages_to_provision = ["prod"]

tags = {
  Account     = "pdnd-probing-prod"
  Layer       = "core"
  CreatedBy   = "Terraform"
  Environment = "prod"
  Owner       = "PagoPA"
  Source      = "https://github.com/pagopa/interop-infra-probing"
}

sso_admin_role_name = "AWSReservedSSO_FullAdmin_"

vpc_id                  = ""
eks_workload_cidrs      = []
eks_control_plane_cidrs = []
aurora_cidrs            = []
msk_cidrs               = []

vpn_clients_security_group_id = ""

interop_msk_clusters_arns = {
  prod = ""
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
github_runners_image_uri     = "ghcr.io/pagopa/interop-github-runner-aws:v1.16.0"

deployment_repo_name = "pagopa/interop-probing-deployment"
