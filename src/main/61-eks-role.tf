module "registry_reader_role" {
  version = "5.18.0"
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

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
    registry_reader_policy  = aws_iam_policy.registry_reader_policy.arn
    xray_integration_policy = data.aws_iam_policy.aws_managed_xray_daemon_write_access.arn
  }
}

module "registry_updater_role" {
  version = "5.18.0"
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

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
    registry_updater_policy = aws_iam_policy.registry_updater_policy.arn
    xray_integration_policy = data.aws_iam_policy.aws_managed_xray_daemon_write_access.arn
  }
}

module "scheduler_role" {
  version = "5.18.0"
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${var.be_prefix}-scheduler-${var.env}"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.env}:${var.be_prefix}-scheduler"]
    }
  }

  role_path        = "/application/eks/pods/"
  role_description = "Role for writing from polling SQS queue"

  role_policy_arns = {
    scheduler_policy        = aws_iam_policy.scheduler_policy.arn
    xray_integration_policy = data.aws_iam_policy.aws_managed_xray_daemon_write_access.arn
  }
}

module "telemetry_writer_role" {
  version = "5.18.0"
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${var.be_prefix}-telemetry-writer-${var.env}"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.env}:${var.be_prefix}-telemetry-writer"]
    }
  }

  role_path        = "/application/eks/pods/"
  role_description = "Role for reading from telemetry SQS queue and write to Timestream"

  role_policy_arns = {
    telemetry_writer_policy = aws_iam_policy.telemetry_writer_policy.arn
    xray_integration_policy = data.aws_iam_policy.aws_managed_xray_daemon_write_access.arn
  }
}

module "caller_role" {
  version = "5.18.0"
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${var.be_prefix}-caller-${var.env}"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.env}:${var.be_prefix}-caller"]
    }
  }

  role_path        = "/application/eks/pods/"
  role_description = "Role for reading and writing from SQSs queue"

  role_policy_arns = {
    caller_policy           = aws_iam_policy.caller_policy.arn
    xray_integration_policy = data.aws_iam_policy.aws_managed_xray_daemon_write_access.arn
  }
}

module "response_updater_role" {
  version = "5.18.0"
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${var.be_prefix}-response-updater-${var.env}"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.env}:${var.be_prefix}-response-updater"]
    }
  }

  role_path        = "/application/eks/pods/"
  role_description = "Role for reading and writing from SQSs queue"

  role_policy_arns = {
    response_updater_policy = aws_iam_policy.response_updater_policy.arn
    xray_integration_policy = data.aws_iam_policy.aws_managed_xray_daemon_write_access.arn
  }
}

module "statistics_api_role" {
  version = "5.18.0"
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${var.be_prefix}-statistics-api-${var.env}"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.env}:${var.be_prefix}-statistics-api"]
    }
  }

  role_path        = "/application/eks/pods/"
  role_description = "Role for reading from timestream DB"

  role_policy_arns = {
    statistics_api_policy   = aws_iam_policy.statistics_api_policy.arn
    xray_integration_policy = data.aws_iam_policy.aws_managed_xray_daemon_write_access.arn
  }
}

module "probing_api_role" {
  version = "5.18.0"
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${var.be_prefix}-api-${var.env}"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.env}:${var.be_prefix}-api"]
    }
  }

  role_path        = "/application/eks/pods/"
  role_description = "Role for probing-api microservice"

  role_policy_arns = {
    xray_integration_policy = data.aws_iam_policy.aws_managed_xray_daemon_write_access.arn
  }
}

module "operations_role" {
  version = "5.18.0"
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${var.be_prefix}-operations-${var.env}"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.env}:${var.be_prefix}-operations"]
    }
  }

  role_path        = "/application/eks/pods/"
  role_description = "Role for operations microservice"

  role_policy_arns = {
    xray_integration_policy = data.aws_iam_policy.aws_managed_xray_daemon_write_access.arn
  }
}

module "aws_load_balancer_controller_role" {
  version = "5.18.0"
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

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
    aws_load_balancer_controller_policy = aws_iam_policy.aws_load_balancer_controller_iam_policy.arn
  }
}

module "adot_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "adot"

  role_policy_arns = {
    cloud_watch = data.aws_iam_policy.aws_managed_cloudwatch_agent_server.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["opentelemetry-operator-system:aws-otel-collector"]
    }
  }
}