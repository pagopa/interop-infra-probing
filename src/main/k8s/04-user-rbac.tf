resource "kubernetes_cluster_role_binding_v1" "readonly_group_view" {
  metadata {
    name = "readonly-group-view"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "readonly-group"
  }
}
