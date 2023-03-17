data "aws_iam_role" "registry_reader" {
  name = format("%s-registry-reader-%s", var.be_prefix, var.env)
}

resource "kubernetes_service_account_v1" "registry_reader" {
  metadata {
    namespace = kubernetes_namespace_v1.env.metadata[0].name
    name      = format("%s-eservice-registry-reader", var.be_prefix)

    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.registry_reader.arn
    }

    labels = {
      "app.kubernetes.io/name" = format("%s-eservice-registry-reader", var.be_prefix)
    }
  }
}

data "aws_iam_role" "registry_updater" {
  name = format("%s-registry-updater-%s", var.be_prefix, var.env)
}

resource "kubernetes_service_account_v1" "registry_updater" {
  metadata {
    namespace = kubernetes_namespace_v1.env.metadata[0].name
    name      = format("%s-eservice-registry-updater", var.be_prefix)

    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.registry_updater.arn
    }

    labels = {
      "app.kubernetes.io/name" = format("%s-eservice-registry-updater", var.be_prefix)
    }
  }
}
