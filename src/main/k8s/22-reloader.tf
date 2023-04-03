resource "helm_release" "reloader" {
  name       = "reloader"
  repository = "https://stakater.github.io/stakater-charts"
  chart      = "reloader"
  version    = "1.0.18"
  namespace  = var.env

  set {
    name  = "reloader.watchGlobally"
    value = "false"
  }
}