aws_region = "eu-central-1"
env        = "dev"
app_name   = "interop-probing"

tags = {
  CreatedBy   = "Terraform"
  Environment = "dev"
  Owner       = "PagoPA"
  Source      = "https://github.com/pagopa/interop-infra-probing"
}

be_prefix                    = "interop-be-probing"
eks_cluster_name             = "interop-probing-eks-dev"
adot_irsa_role_arn           = "arn:aws:iam::774300547186:role/adot"
fargate_profiles_roles_names = ["SystemProfile-20230228142846109700000003", "ApplicationProfile-20230228142846109000000001", "ObservabilityProfile-20230317172642820300000001"]
sso_full_admin_role_name     = "AWSReservedSSO_FullAdmin_43e33324db7f1652"
infra_repo_role_name         = "GithubActionIACRole"
k8s_repo_role_name           = "interop-be-probing-k8s-deploy-dev"
adot_collector_img_tag       = "v0.30.0"
metrics_server_img_tag       = "v0.6.3"

iam_users_k8s_readonly           = ["eduardo.mihalache"]
enable_fluentbit_process_logs = false
container_logs_retention_days = 180

