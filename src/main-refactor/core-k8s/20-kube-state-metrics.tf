resource "helm_release" "kube_state_metrics" {
  name       = "kube-state-metrics"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  version    = "5.19.1"
  namespace  = kubernetes_namespace_v1.aws_observability.metadata[0].name

  set {
    name  = "image.tag"
    value = var.kube_state_metrics_image_version_tag
  }

  set {
    name  = "resources.requests.cpu"
    value = var.kube_state_metrics_cpu
  }

  set {
    name  = "resources.requests.memory"
    value = var.kube_state_metrics_memory
  }

  set {
    name  = "selfMonitor.enabled"
    value = true
  }
}
