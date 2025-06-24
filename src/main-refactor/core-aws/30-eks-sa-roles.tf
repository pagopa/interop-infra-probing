locals {
  be_prefix = format("%s-be", local.project)
}

data "aws_iam_policy" "aws_managed_cloudwatch_agent_server" {
  name = "CloudWatchAgentServerPolicy"
}

#### SYSTEM ROLES ####

data "aws_iam_policy" "cloudwatch_agent_server" {
  name = "CloudWatchAgentServerPolicy"
}

module "aws_lb_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.39.1"

  role_name = format("aws-load-balancer-controller-%s", var.env)

  oidc_providers = {
    cluster = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  attach_load_balancer_controller_targetgroup_binding_only_policy = true
}

module "adot_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.39.1"

  role_name = format("adot-collector-%s", var.env)

  oidc_providers = {
    eks = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["aws-observability:adot-collector"]
    }
  }

  role_policy_arns = {
    cloudwatch = data.aws_iam_policy.cloudwatch_agent_server.arn
  }
}
