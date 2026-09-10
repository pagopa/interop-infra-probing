resource "aws_iam_policy" "fargate_profile_logging" {
  name = "EKSFargateProfileLogging"

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
          "logs:PutRetentionPolicy",
          "logs:DeleteRetentionPolicy"
        ]
        Resource = "*"
      }
    ]
  })
}

locals {
  system_namespaces        = ["kube-system"]
  application_namespaces   = [for stage in var.stages_to_provision : format("%s*", stage)]
  observability_namespaces = ["aws-observability"]
  tools_namespaces         = local.deploy_keda ? ["keda"] : []
}

module "eks" {
  # Necessary otherwise the module tries to create an access entry for the deployment role before the role is created.
  # This situation will cause the following error: "operation error EKS: CreateAccessEntry, https response error StatusCode: 400, InvalidParameterException: The specified principalArn is invalid: invalid principal." 
  depends_on = [aws_iam_role.deployment_github_repo]

  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = format("%s-eks-cluster-%s", local.project, var.env)
  kubernetes_version = var.eks_k8s_version

  vpc_id                   = data.aws_vpc.probing.id
  control_plane_subnet_ids = data.aws_subnets.eks_control_plane.ids
  ip_family                = "ipv4"
  # CIDR range for K8s services IPs. Just to avoid potential overlap with other networks
  service_ipv4_cidr = "10.1.0.0/21"

  node_security_group_enable_recommended_rules = false

  security_group_additional_rules = {
    from_github_runners = {
      type                     = "ingress"
      from_port                = 0
      to_port                  = 65535
      protocol                 = "tcp"
      source_security_group_id = aws_security_group.github_runners.id
    }

    from_vpn_clients = {
      description              = "From VPN clients"
      type                     = "ingress"
      from_port                = 0
      to_port                  = 65535
      protocol                 = "tcp"
      source_security_group_id = data.aws_security_group.vpn_clients.id
    }
  }

  endpoint_public_access  = false
  endpoint_private_access = true
  authentication_mode     = "API_AND_CONFIG_MAP"

  access_entries = merge(
    {
      sso_full_admin = {
        principal_arn     = data.aws_iam_role.sso_admin.arn
        kubernetes_groups = []

        policy_associations = {
          cluster_admin = {
            policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
            access_scope = {
              namespaces = []
              type       = "cluster"
            }
          }
        }
      }
    },
    {
      deployment_role = {
        principal_arn     = local.deployment_github_repo_iam_role_arn
        kubernetes_groups = []

        policy_associations = {
          namespace_edit = {
            policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
            access_scope = {
              type       = "namespace"
              namespaces = concat(["default"], [for ns in local.application_namespaces : ns]) #TOCHECK: Should the deployment role for an env (e.g. dev) have access to all the application namesoaces in the cluster (e.g. dev*, qa*, vapt*)?
            }
          }
        }
      }
    }
  )

  security_group_use_name_prefix = false
  security_group_name            = format("eks/cp-eni/%s-eks-cluster-%s", local.project, var.env)

  iam_role_use_name_prefix = false
  iam_role_name            = format("%s-eks-cluster-%s", local.project, var.env)

  enabled_log_types                      = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cloudwatch_log_group_retention_in_days = var.env == "prod" ? 365 : 90

  kms_key_enable_default_policy = true
  kms_key_administrators = [
    data.aws_iam_role.sso_admin.arn
  ]

  fargate_profiles = merge({
    system = {
      subnet_ids               = data.aws_subnets.eks_workload.ids
      name                     = format("%s-fargate-system-profile-%s", local.project, var.env)
      selectors                = [for ns in local.system_namespaces : { namespace = ns }]
      iam_role_use_name_prefix = false
      iam_role_additional_policies = {
        fargate_logging = aws_iam_policy.fargate_profile_logging.arn
      }
    }
    application = {
      subnet_ids               = data.aws_subnets.eks_workload.ids
      name                     = format("%s-fargate-app-profile-%s", local.project, var.env) # e.g. the "probing-fargate-app-profile-dev" schedules on fargate all the pods in the application namespaces (dev, qa, vapt) in the dev cluster.
      selectors                = [for ns in local.application_namespaces : { namespace = ns }]
      iam_role_use_name_prefix = false
      iam_role_additional_policies = {
        fargate_logging = aws_iam_policy.fargate_profile_logging.arn
      }
    }
    observability = {
      subnet_ids               = data.aws_subnets.eks_workload.ids
      name                     = format("%s-fargate-obs-profile-%s", local.project, var.env)
      selectors                = [for ns in local.observability_namespaces : { namespace = ns }]
      iam_role_use_name_prefix = false
      iam_role_additional_policies = {
        fargate_logging = aws_iam_policy.fargate_profile_logging.arn
      }
    } },
    length(local.tools_namespaces) > 0 ? ({
      tools = {
        subnet_ids               = data.aws_subnets.eks_workload.ids
        name                     = format("%s-fargate-tools-profile-%s", local.project, var.env)
        selectors                = [for ns in local.tools_namespaces : { namespace = ns }]
        iam_role_use_name_prefix = false
        iam_role_additional_policies = {
          fargate_logging = aws_iam_policy.fargate_profile_logging.arn
        }
      }
    }) : {}
  )

  addons = {
    vpc-cni = {
      addon_version               = var.eks_vpc_cni_version
      most_recent                 = false # use 'default' version for the K8s version
      resolve_conflicts_on_create = "NONE"
      resolve_conflicts_on_update = "NONE"
    }

    coredns = {
      addon_version               = var.eks_coredns_version
      most_recent                 = false # use 'default' version for the K8s version
      resolve_conflicts_on_create = "NONE"
      resolve_conflicts_on_update = "NONE"
    }

    kube-proxy = {
      addon_version               = var.eks_kube_proxy_version
      most_recent                 = false # use 'default' version for the K8s version
      resolve_conflicts_on_create = "NONE"
      resolve_conflicts_on_update = "NONE"
    }
  }
}
