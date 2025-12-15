aws_region = "eu-south-1"
env        = "dev"
stage      = "dev"
azs        = ["eu-south-1a", "eu-south-1b", "eu-south-1c"]

tags = {
  Account     = "pdnd-probing-dev"
  Layer       = "stages"
  Stage       = "dev"
  CreatedBy   = "Terraform"
  Environment = "dev"
  Owner       = "PagoPA"
  Source      = "https://github.com/pagopa/interop-infra-probing"
}

sso_admin_role_name = "AWSReservedSSO_FullAdmin_bd35c1497d9407bb"

vpc_id = "vpc-0e2fb2d5964ac4d11"

interop_msk_cluster_arn = "arn:aws:kafka:eu-south-1:505630707203:cluster/interop-platform-events-dev/259df37b-31c3-405c-bb30-d2bce2ca67c6-2"

probing_operational_database_cluster_identifier = "probing-store-dev"
probing_operational_database_name               = "interop_probing_operational_dev"

probing_analytics_database_name = "interop_probing_telemetry"

timestream_table_magnetic_store_retention_period_in_days = 73000
timestream_table_memory_store_retention_period_in_hours  = 8766

int_lbs_cidrs = ["10.0.27.0/24", "10.0.28.0/24", "10.0.29.0/24"]

probing_base_route53_zone_name = "dev.stato-eservice.interop.pagopa.it"

fe_base_url = "https://dev.stato-eservice.interop.pagopa.it"

backend_microservices_port = 8080

probing_openapi_path = "./openapi/dev/interop-probing-dev-api-v2.yaml"

eks_cluster_name = "probing-eks-cluster-dev"

jwks_uri = "https://dev.interop.pagopa.it/.well-known/probing-jwks.json"

timestream_instance_name         = "probing-analytics-dev"
timestream_instance_port         = "8086"
timestream_instance_id           = "iyyprotlvq"
timestream_instance_endpoint     = "iyyprotlvq-p2jepkxlcngatz.timestream-influxdb.eu-south-1.on.aws"
timestream_instance_organization = "probing-analytics-dev"
timestream_instance_bucket_name  = "probing-telemetry-dev"

probing_analytics_admin_secret_name = "timestream/probing-analytics-dev/users/admin"

probing_deployment_github_repo_role_name = "probing-deployment-github-repo-dev"

eks_application_log_group_name = "/aws/eks/probing-eks-cluster-dev/application"
