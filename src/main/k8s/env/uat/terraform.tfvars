aws_region = "eu-central-1"
env        = "uat"
app_name   = "interop-probing"

tags = {
  CreatedBy   = "Terraform"
  Environment = "uat"
  Owner       = "PagoPA"
  Source      = "https://github.com/pagopa/interop-infra-probing"
}

be_prefix                    = "interop-be-probing"
eks_cluster_name             = "interop-probing-eks-uat"
adot_irsa_role_arn           = "arn:aws:iam::010158505074:role/adot"
fargate_profiles_roles_names = ["SystemProfile-20230228142846109700000003", "ApplicationProfile-20230228142846109000000001", "ObservabilityProfile-20230317172642820300000001"]
sso_full_admin_role_name     = "AWSReservedSSO_FullAdmin_010f7fe5de34c177"
infra_repo_role_name         = "GithubActionIACRole"
k8s_repo_role_name           = "interop-be-probing-k8s-deploy-uat"
adot_collector_img_tag       = "v0.30.0"
metrics_server_img_tag       = "v0.6.3"

enable_fluentbit_process_logs = false
container_logs_retention_days = 180

