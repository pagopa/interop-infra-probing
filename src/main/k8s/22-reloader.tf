resource "helm_release" "reloader" {
  name       = "stakater/reloader"
  repository = "https://stakater.github.io/stakater-charts"
  chart      = "stakater/reloader"
  version    = "1.0.15"
  namespace  = var.env

  set {
    name  = "reloader.watchGlobally=false"
    value = "false"
  }
}