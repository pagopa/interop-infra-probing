module "registry_reader_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${var.be_prefix}-registry-reader-${var.env}"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.env}:${var.be_prefix}-eservice-registry-reader"]
    }
  }

  role_path        = "/application/eks/pods/"
  role_description = "Role for Read from probing bucket and write on SQS queue"

  role_policy_arns = {
    registry_reader_policy = aws_iam_policy.registry_reader_policy.arn
  }
}

module "registry_updater_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${var.be_prefix}-registry-updater-${var.env}"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.env}:${var.be_prefix}-eservice-registry-updater"]
    }
  }

  role_path        = "/application/eks/pods/"
  role_description = "Role for Read from registry SQS queue"

  role_policy_arns = {
    registry_reader_policy = aws_iam_policy.registry_updater_policy.arn
  }
}

module "aws_load_balancer_controller_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "aws-load-balancer-controller"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  role_path        = "/infra/eks/pods/"
  role_description = "Role for AWS Load Balancer Controller"

  role_policy_arns = {
    registry_reader_policy = data.aws_iam_policy.aws_load_balancer_controller_iam_policy.arn
  }
}
