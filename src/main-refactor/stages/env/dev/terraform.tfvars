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

interop_msk_cluster_arn = "arn:aws:kafka:eu-south-1:774300547186:vpc-connection/505630707203/interop-platform-events-dev/0c3359f3-92be-4f3e-a52f-9f1b75dfe7df-2"

probing_operational_database_cluster_identifier = "probing-store-dev" #TOCHECK
probing_operational_database_name               = "interop_probing_operational_dev"

probing_analytics_database_name = "interop_probing_telemetry"

timestream_table_magnetic_store_retention_period_in_days = 73000
timestream_table_memory_store_retention_period_in_hours  = 8766

int_lbs_cidrs = ["10.0.27.0/24", "10.0.28.0/24", "10.0.29.0/24"]

probing_base_route53_zone_name = "dev.stato-eservice.interop.pagopa.it"

fe_base_url = "https://dev.stato-eservice.interop.pagopa.it"

backend_microservices_port = 8080

probing_openapi_path = "./openapi/dev/interop-probing-dev-api-v1.yaml"

eks_cluster_name = "probing-eks-cluster-dev"

jwks_uri = "https://dev.interop.pagopa.it/.well-known/probing-jwks.json"

timestream_instance_name         = "probing-analytics-dev"
timestream_instance_port         = "8086"
timestream_instance_id           = "iyyprotlvq"
timestream_instance_endpoint     = "iyyprotlvq-p2jepkxlcngatz.timestream-influxdb.eu-south-1.on.aws"
timestream_instance_organization = "probing-analytics-dev"
timestream_instance_bucket_name  = "probing-telemetry-dev"

probing_analytics_admin_secret_name = "timestream/probing-analytics-dev/users/admin"