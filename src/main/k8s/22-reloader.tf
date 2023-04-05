resource "helm_release" "reloader" {
  name       = "reloader"
  repository = "https://stakater.github.io/stakater-charts"
  chart      = "reloader"
  version    = "1.0.18"
  namespace  = kubernetes_namespace_v1.env.metadata[0].name

  set {
    name  = "reloader.watchGlobally"
    value = "false"
  }
}