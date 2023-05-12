locals {
  fargate_profiles_mapping = [for role in data.aws_iam_role.fargate_profiles : templatefile("./templates/aws-auth-role.tpl",
    {
      role_arn     = role.arn
      k8s_username = "system:node:{{SessionName}}"
      k8s_groups   = ["system:bootstrappers", "system:nodes", "system:node-proxier"]
  })]

  sso_full_admin_mapping = templatefile("./templates/aws-auth-role.tpl",
    {
      # cannot use data object for the SSO role because it would return a different ARN format
      role_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.sso_full_admin_role_name}"
      k8s_username = "sso-fulladmin-{{SessionName}}"
      k8s_groups   = ["system:masters"]
  })

  infra_deploy_mapping = templatefile("./templates/aws-auth-role.tpl",
    {
      role_arn     = data.aws_iam_role.infra_deploy.arn
      k8s_username = var.infra_repo_role_name
      k8s_groups   = ["system:masters"]
  })

  k8s_deploy_mapping = templatefile("./templates/aws-auth-role.tpl",
    {
      role_arn     = data.aws_iam_role.k8s_deploy.arn
      k8s_username = var.k8s_repo_role_name
      k8s_groups   = ["system:masters"]
  })

  admin_users_mapping = [for user in data.aws_iam_user.admin : templatefile("./templates/aws-auth-user.tpl",
    {
      user_arn     = user.arn
      k8s_username = user.user_name
      k8s_groups   = ["system:masters"]
  })]
}

data "aws_iam_role" "fargate_profiles" {
  for_each = toset(var.fargate_profiles_roles_names)

  name = each.key
}

data "aws_iam_role" "infra_deploy" {
  name = var.infra_repo_role_name
}

data "aws_iam_role" "k8s_deploy" {
  name = var.k8s_repo_role_name
}

data "aws_iam_user" "admin" {
  for_each = toset(var.iam_users_k8s_admin)

  user_name = each.key
}

resource "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = join("", concat(local.fargate_profiles_mapping, [local.sso_full_admin_mapping, local.infra_deploy_mapping, local.k8s_deploy_mapping]))
    mapUsers = length(local.admin_users_mapping) > 0 ? join("", local.admin_users_mapping) : null
  }
}
