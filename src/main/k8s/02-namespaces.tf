resource "kubernetes_namespace_v1" "env" {
  metadata {
    name = var.env
  }
}
