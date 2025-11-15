resource "kubernetes_namespace_v1" "env" {
  metadata {
    name = var.stage

    labels = {
      "elbv2.k8s.aws/pod-readiness-gate-inject" : "enabled"
    }
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

resource "kubernetes_namespace_v1" "keda" {
  count = local.deploy_keda ? 1 : 0

  metadata {
    name = "keda"
  }
}
