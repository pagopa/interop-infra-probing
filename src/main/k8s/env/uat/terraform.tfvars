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
fargate_profiles_roles_names = ["ApplicationProfile-20230711133023431000000006", "ObservabilityProfile-20230711133023779600000008", "SystemProfile-20230711133023582000000007"]
sso_full_admin_role_name     = "AWSReservedSSO_FullAdmin_010f7fe5de34c177"
infra_repo_role_name         = "GithubActionIACRole"
k8s_repo_role_name           = "interop-be-probing-k8s-deploy-uat"
adot_collector_img_tag       = "v0.30.0"
metrics_server_img_tag       = "v0.6.3"

iam_users_k8s_readonly        = ["giuseppe.dellorusso"]
enable_fluentbit_process_logs = false
container_logs_retention_days = 180