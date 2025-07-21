locals {
  json_data = jsondecode(file("./assets/eks-access/eks-access-${var.env}.json"))

  principals = [
    for p in local.json_data.iam_principals : {
      principal_arn       = p.principal_arn
      kubernetes_username = try(p.kubernetes_username, null)
      kubernetes_groups   = p.kubernetes_groups
    }
  ]

  access_policies = flatten([
    for p in local.json_data.iam_principals : [
      for ap in try(p.access_policies, []) : {
        principal_arn = p.principal_arn
        scope         = ap.scope
        namespaces    = try(ap.namespaces, null)
        policy_arn    = ap.eks_policy_arn
      }
    ]
  ])
}

resource "aws_eks_access_entry" "this" {
  for_each = { for item in local.principals : "${item.principal_arn}" => item }

  cluster_name      = module.eks.cluster_name
  principal_arn     = each.value.principal_arn
  user_name         = each.value.kubernetes_username != null ? each.value.kubernetes_username : null
  kubernetes_groups = length(each.value.kubernetes_groups) > 0 ? each.value.kubernetes_groups : []
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "this" {
  # This for_each takes as input a map which is made by key-value pairs. 
  # Each key is obtained by concatenating the principal_arn with the policy arn. 
  # Each value contains the following attributes: principal_arn, policy_arn, scope, namespaces (which is a tuple).
  for_each = { for item in local.access_policies : "${item.principal_arn}-${item.policy_arn}" => item }

  cluster_name  = module.eks.cluster_name
  policy_arn    = each.value.policy_arn
  principal_arn = each.value.principal_arn

  access_scope {
    type       = each.value.scope
    namespaces = each.value.namespaces != null ? each.value.namespaces : null
  }
}
