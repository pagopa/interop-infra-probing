aws_region = "eu-south-1"
env        = "uat"
stage      = "att"
azs        = ["eu-south-1a", "eu-south-1b", "eu-south-1c"]

tags = {
  Account     = "pdnd-probing-uat"
  Layer       = "stages"
  Stage       = "att"
  CreatedBy   = "Terraform"
  Environment = "uat"
  Owner       = "PagoPA"
  Source      = "https://github.com/pagopa/interop-infra-probing"
}

sso_admin_role_name = "AWSReservedSSO_FullAdmin_4c15f6000e5b2a27"

vpc_id = "vpc-0acbd5bcdb93a591d"

interop_msk_cluster_arn = "arn:aws:kafka:eu-south-1:533267098416:cluster/interop-platform-events-att/ab17674c-f6d6-4a0b-a844-faab53eee76e-3"

probing_operational_database_cluster_identifier = "probing-store-uat"
probing_operational_database_name               = "interop_probing_operational_att"

int_lbs_cidrs = ["10.0.27.0/24", "10.0.28.0/24", "10.0.29.0/24"]

probing_base_route53_zone_name = "att.stato-eservice.interop.pagopa.it"

fe_base_url = "https://att.stato-eservice.interop.pagopa.it"

backend_microservices_port = 8080

probing_openapi_path = "./openapi/att/interop-probing-att-api-v2.yaml"

eks_cluster_name = "probing-eks-cluster-uat"

jwks_uri = "https://att.interop.pagopa.it/.well-known/probing-jwks.json"

timestream_instance_name         = "probing-analytics-uat"
timestream_instance_port         = "8086"
timestream_instance_id           = "wz5wkydgr2"
timestream_instance_endpoint     = "wz5wkydgr2-a2sqrsogbxh5nt.timestream-influxdb.eu-south-1.on.aws"
timestream_instance_organization = "probing-analytics-uat"
timestream_instance_bucket_name  = "probing-telemetry-att"

probing_analytics_admin_secret_name = "timestream/probing-analytics-uat/users/admin"

probing_deployment_github_repo_role_name = "probing-deployment-github-repo-uat"

eks_application_log_group_name = "/aws/eks/probing-eks-cluster-uat/application"

backoffice_users_repo_name = "pagopa/interop-probing-backoffice-users"
