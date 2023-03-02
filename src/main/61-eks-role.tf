module "registry_reader_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "registryReaderRole"

  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["dev-registry-reader:registry-reader"]
    }
  }

  role_path        = "/infra/eks/pods/"
  role_description = "Role for Read from probing bucket and write on SQS queue"

  role_policy_arns = {
    registry_reader_policy = aws_iam_policy.registry_reader_policy.arn
  }
}