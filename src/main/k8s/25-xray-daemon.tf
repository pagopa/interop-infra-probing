resource "kubernetes_manifest" "xray_daemon" {
  for_each = fileset("${path.module}/assets/xray_daemon/", "*.yaml")

  manifest = yamldecode(templatefile("${path.module}/assets/xray_daemon/${each.value}", {
    cluster_name                = var.eks_cluster_name
    namespace                   = "aws-observability"
    xray_daemon_img_version     = "3.3.7"
    xray_daemon_service_account = "xray-daemon"
  }))
  field_manager {
    force_conflicts = true
  }

  field_manager {
    force_conflicts = true
  }

}