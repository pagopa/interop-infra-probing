# resource "helm_release" "cert_manager" {
#   name       = "cert-manager"
#   chart      = "cert-manager"
#   repository = "https://charts.jetstack.io"
#   version    = "1.12.1"
#   namespace  = "kube-system"

#   set {
#     name  = "webhook.securePort"
#     value = 10260
#   }

#   set {
#     name  = "installCRDs"
#     value = true
#   }
# }