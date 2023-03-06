module "registry_reader_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${var.app_name}-registry-reader-${var.env}"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.env}:registry-reader"]
    }
  }

  role_path        = "/application/eks/pods/"
  role_description = "Role for Read from probing bucket and write on SQS queue"

  role_policy_arns = {
    registry_reader_policy = aws_iam_policy.registry_reader_policy.arn
  }
}