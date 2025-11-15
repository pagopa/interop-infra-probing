resource "kubernetes_role_v1" "tgb_manager" {
  metadata {
    name      = "tgb-manager-role"
    namespace = kubernetes_namespace_v1.env.metadata[0].name
  }

  rule {
    api_groups = ["elbv2.k8s.aws"]
    resources  = ["targetgroupbindings"]
    verbs      = ["create", "get", "list", "watch", "update", "delete", "patch"]
  }
}

resource "kubernetes_role_binding_v1" "tgb_manager" {
  metadata {
    name      = "tgb-manager-binding"
    namespace = kubernetes_namespace_v1.env.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.tgb_manager.metadata[0].name
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "tgb-manager-group"
  }
}

resource "kubernetes_role_v1" "keda_objects_manager" {
  count = local.deploy_keda ? 1 : 0

  metadata {
    name      = "keda-objects-manager-role"
    namespace = kubernetes_namespace_v1.env.metadata[0].name
  }

  rule {
    api_groups = ["keda.sh"]
    resources  = ["scaledobjects", "scaledjobs", "triggerauthentications"]
    verbs      = ["create", "get", "list", "watch", "update", "delete", "patch"]
  }
}

resource "kubernetes_role_binding_v1" "keda_objects_manager" {
  count = local.deploy_keda ? 1 : 0

  metadata {
    name      = "keda-objects-manager-binding"
    namespace = kubernetes_namespace_v1.env.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.keda_objects_manager[0].metadata[0].name
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "keda-objects-manager-group"
  }
}
