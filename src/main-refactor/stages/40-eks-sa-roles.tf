locals {
  be_prefix = format("%s-be", local.project)
}

#### APP ROLES ####

module "be_api_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.39.1"

  role_name = format("%s-api-%s", local.be_prefix, var.stage)

  oidc_providers = {
    cluster = {
      provider_arn               = data.aws_iam_openid_connect_provider.probing_eks.arn
      namespace_service_accounts = ["${var.stage}:${local.be_prefix}-api"]
    }
  }

  role_policy_arns = {}
}

module "be_scheduler_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.39.1"

  role_name = format("%s-scheduler-%s", local.be_prefix, var.stage)

  oidc_providers = {
    cluster = {
      provider_arn               = data.aws_iam_openid_connect_provider.probing_eks.arn
      namespace_service_accounts = ["${var.stage}:${local.be_prefix}-scheduler"]
    }
  }

  role_policy_arns = {
    be_scheduler = aws_iam_policy.be_scheduler.arn
  }
}

module "be_telemetry_writer_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.39.1"

  role_name = format("%s-telemetry-writer-%s", local.be_prefix, var.stage)

  oidc_providers = {
    cluster = {
      provider_arn               = data.aws_iam_openid_connect_provider.probing_eks.arn
      namespace_service_accounts = ["${var.stage}:${local.be_prefix}-telemetry-writer"]
    }
  }

  role_policy_arns = {
    be_scheduler = aws_iam_policy.be_telemetry_writer.arn
  }
}

module "be_caller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.39.1"

  role_name = format("%s-caller-%s", local.be_prefix, var.stage)

  oidc_providers = {
    cluster = {
      provider_arn               = data.aws_iam_openid_connect_provider.probing_eks.arn
      namespace_service_accounts = ["${var.stage}:${local.be_prefix}-caller"]
    }
  }

  role_policy_arns = {
    be_scheduler = aws_iam_policy.be_caller.arn
  }
}

module "be_response_updater_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.39.1"

  role_name = format("%s-response-updater-%s", local.be_prefix, var.stage)

  oidc_providers = {
    cluster = {
      provider_arn               = data.aws_iam_openid_connect_provider.probing_eks.arn
      namespace_service_accounts = ["${var.stage}:${local.be_prefix}-response-updater"]
    }
  }

  role_policy_arns = {
    be_scheduler = aws_iam_policy.be_response_updater.arn
  }
}

module "be_statistics_api_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.39.1"

  role_name = format("%s-statistics-api-%s", local.be_prefix, var.stage)

  oidc_providers = {
    cluster = {
      provider_arn               = data.aws_iam_openid_connect_provider.probing_eks.arn
      namespace_service_accounts = ["${var.stage}:${local.be_prefix}-statistics-api"]
    }
  }

  role_policy_arns = {
    be_scheduler = aws_iam_policy.be_statistics_api.arn
  }
}