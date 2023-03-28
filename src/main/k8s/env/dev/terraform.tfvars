aws_region = "eu-central-1"
env        = "dev"
app_name   = "interop-probing"

tags = {
  CreatedBy   = "Terraform"
  Environment = "dev"
  Owner       = "PagoPA"
  Source      = "https://github.com/pagopa/interop-infra-probing"
}

be_prefix        = "interop-be-probing"
eks_cluster_name = "interop-probing-eks-dev"

fargate_profiles_roles_names  = ["SystemProfile-20230228142846109700000003", "ApplicationProfile-20230228142846109000000001", "ObservabilityProfile-20230317172642820300000001"]
sso_full_admin_role_name      = "AWSReservedSSO_FullAdmin_43e33324db7f1652"
iam_users_k8s_admin           = ["alessio.creo", "alessandro.colella", "giuseppe.porro", "giuseppe.dellorusso"]
enable_fluentbit_process_logs = false
container_logs_retention_days = 180