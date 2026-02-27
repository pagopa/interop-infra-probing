aws_region = "eu-south-1"
env        = "uat"
stage      = "uat"
azs        = ["eu-south-1a", "eu-south-1b", "eu-south-1c"]

tags = {
  Account     = "pdnd-probing-uat"
  Layer       = "stages"
  Stage       = "uat"
  CreatedBy   = "Terraform"
  Environment = "uat"
  Owner       = "PagoPA"
  Source      = "https://github.com/pagopa/interop-infra-probing"
}

sso_admin_role_name = "AWSReservedSSO_FullAdmin_4c15f6000e5b2a27"

vpc_id = "vpc-0acbd5bcdb93a591d"

interop_msk_cluster_arn = "arn:aws:kafka:eu-south-1:895646477129:cluster/interop-platform-events-test/2952348f-d39d-47b2-925c-bd3edc78000c-3"

probing_operational_database_cluster_identifier = "probing-store-uat"
probing_operational_database_name               = "interop_probing_operational_uat"

int_lbs_cidrs = ["10.0.27.0/24", "10.0.28.0/24", "10.0.29.0/24"]

probing_base_route53_zone_name = "uat.stato-eservice.interop.pagopa.it"

fe_base_url = "https://uat.stato-eservice.interop.pagopa.it"

backend_microservices_port = 8080

probing_openapi_path = "./openapi/uat/interop-probing-uat-api-v2.yaml"

eks_cluster_name = "probing-eks-cluster-uat"

jwks_uri = "https://uat.interop.pagopa.it/.well-known/probing-jwks.json"

timestream_instance_name         = "probing-analytics-uat"
timestream_instance_port         = "8086"
timestream_instance_id           = ""
timestream_instance_endpoint     = ".timestream-influxdb.eu-south-1.on.aws"
timestream_instance_organization = "probing-analytics-uat"
timestream_instance_bucket_name  = "probing-telemetry-uat"

probing_analytics_admin_secret_name = "timestream/probing-analytics-uat/users/admin"

probing_deployment_github_repo_role_name = "probing-deployment-github-repo-uat"

eks_application_log_group_name = "/aws/eks/probing-eks-cluster-uat/application"

backoffice_users_repo_name = "pagopa/interop-probing-backoffice-users"
