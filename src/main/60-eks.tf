locals {
  system_namespaces        = ["kube-system"]
  application_namespaces   = [format("%s*", var.env), "default"]
  observability_namespaces = ["aws-observability"]
}

resource "aws_iam_policy" "fargate_profile_logging" {
  name = "EksFargateProfileLogging"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:putRetentionPolicy",
          "logs:DeleteRetentionPolicy"
        ]
        Resource = "*"
      }
    ]
  })
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.10.0"

  cluster_name    = "${var.app_name}-eks-${var.env}"
  cluster_version = var.kubernetes_version

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  kms_key_enable_default_policy = true
  kms_key_administrators = [
    data.aws_iam_role.github_iac.arn,
    data.aws_iam_role.sso_admin.arn
  ]

  cluster_addons = {
    kube-proxy = {
      addon_version     = var.kubernetes_addons_versions.kube-proxy
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      addon_version     = var.kubernetes_addons_versions.vpc-cni
      resolve_conflicts = "OVERWRITE"
    }
    coredns = {
      addon_version     = var.kubernetes_addons_versions.coredns
      resolve_conflicts = "OVERWRITE"

      configuration_values = jsonencode({
        computeType = "Fargate"
      })
    }
  }

  vpc_id                   = module.vpc.vpc_id
  control_plane_subnet_ids = data.aws_subnets.control_plane.ids
  subnet_ids               = data.aws_subnets.workload.ids

  create_cluster_security_group = true
  create_node_security_group    = false

  fargate_profile_defaults = {
    iam_role_additional_policies = {
      fargate_logging = aws_iam_policy.fargate_profile_logging.arn
    }

    timeouts = {
      create = "20m"
      delete = "20m"
    }
  }

  fargate_profiles = {
    system = {
      name      = "SystemProfile"
      selectors = [for ns in local.system_namespaces : { namespace = ns }]
    }

    application = {
      name      = "ApplicationProfile"
      selectors = [for ns in local.application_namespaces : { namespace = ns }]
    }

    observability = {
      name      = "ObservabilityProfile"
      selectors = [for ns in local.observability_namespaces : { namespace = ns }]
    }
  }

  cluster_enabled_log_types              = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cloudwatch_log_group_retention_in_days = var.env == "prod" ? 365 : 90
}



