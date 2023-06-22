resource "kubernetes_manifest" "metrics_server" {
  for_each = fileset("${path.module}/assets/metrics_server/", "*.yaml")

  manifest = yamldecode(file("${path.module}/assets/metrics_server/${each.value}"))
  field_manager {
    force_conflicts = true
  }
}