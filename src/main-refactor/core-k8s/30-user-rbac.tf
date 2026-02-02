resource "kubernetes_role_v1" "tgb_manager" {
  for_each = toset(var.stages_to_provision)

  metadata {
    name      = "tgb-manager-role"
    namespace = kubernetes_namespace_v1.env[each.key].metadata[0].name
  }

  rule {
    api_groups = ["elbv2.k8s.aws"]
    resources  = ["targetgroupbindings"]
    verbs      = ["create", "get", "list", "watch", "update", "delete", "patch"]
  }
}

resource "kubernetes_role_binding_v1" "tgb_manager" {
  for_each = toset(var.stages_to_provision)

  metadata {
    name      = "tgb-manager-binding"
    namespace = kubernetes_namespace_v1.env[each.key].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.tgb_manager[each.key].metadata[0].name
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "tgb-manager-group"
  }
}

resource "kubernetes_role_v1" "keda_objects_manager" {
  for_each = local.deploy_keda ? toset(var.stages_to_provision) : toset([])

  metadata {
    name      = "keda-objects-manager-role"
    namespace = kubernetes_namespace_v1.env[each.key].metadata[0].name
  }

  rule {
    api_groups = ["keda.sh"]
    resources  = ["scaledobjects", "scaledjobs", "triggerauthentications"]
    verbs      = ["create", "get", "list", "watch", "update", "delete", "patch"]
  }
}

resource "kubernetes_role_binding_v1" "keda_objects_manager" {
  for_each = local.deploy_keda ? toset(var.stages_to_provision) : toset([])

  metadata {
    name      = "keda-objects-manager-binding"
    namespace = kubernetes_namespace_v1.env[each.key].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.keda_objects_manager[each.key].metadata[0].name
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "keda-objects-manager-group"
  }
}

resource "kubernetes_cluster_role_v1" "port_forward" {
  count = var.env != "prod" ? 1 : 0

  metadata {
    name = "port-forward-role"
  }

  rule {
    api_groups = [""]
    resources  = ["pods/portforward"]
    verbs      = ["create"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "port_forward" {
  count = var.env != "prod" ? 1 : 0

  metadata {
    name      = "port-forward"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.port_forward[0].metadata[0].name
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "port-forwarders-group"
  }
}

