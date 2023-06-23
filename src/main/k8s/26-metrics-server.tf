resource "kubernetes_manifest" "metrics_server" {
  for_each = fileset("${path.module}/assets/metrics_server/", "*.yaml")

  manifest = yamldecode(templatefile("${path.module}/assets/metrics_server/${each.value}",{metrics_server_img_tag=var.metrics_server_img_tag}))
  field_manager {
    force_conflicts = true
  }
}