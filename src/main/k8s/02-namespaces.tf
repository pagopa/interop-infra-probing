resource "kubernetes_namespace_v1" "env" {
  metadata {
    name = var.env
  }
}

resource "kubernetes_namespace_v1" "aws_observability" {
  metadata {
    name = "aws-observability"

    labels = {
      aws-observability = "enabled"
    }
  }
}
