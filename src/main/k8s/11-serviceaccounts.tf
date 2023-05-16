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

data "aws_iam_role" "scheduler" {
  name = format("%s-scheduler-%s", var.be_prefix, var.env)
}

resource "kubernetes_service_account_v1" "scheduler" {
  metadata {
    namespace = kubernetes_namespace_v1.env.metadata[0].name
    name      = format("%s-scheduler", var.be_prefix)

    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.scheduler.arn
    }

    labels = {
      "app.kubernetes.io/name" = format("%s-scheduler", var.be_prefix)
    }
  }
}

data "aws_iam_role" "telemetry-writer" {
  name = format("%s-telemetry-writer-%s", var.be_prefix, var.env)
}

resource "kubernetes_service_account_v1" "telemetry-writer" {
  metadata {
    namespace = kubernetes_namespace_v1.env.metadata[0].name
    name      = format("%s-telemetry-writer", var.be_prefix)

    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.telemetry-writer.arn
    }

    labels = {
      "app.kubernetes.io/name" = format("%s-telemetry-writer", var.be_prefix)
    }
  }
}

data "aws_iam_role" "caller" {
  name = format("%s-caller-%s", var.be_prefix, var.env)
}

resource "kubernetes_service_account_v1" "caller" {
  metadata {
    namespace = kubernetes_namespace_v1.env.metadata[0].name
    name      = format("%s-caller", var.be_prefix)

    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.caller.arn
    }

    labels = {
      "app.kubernetes.io/name" = format("%s-caller", var.be_prefix)
    }
  }
}

data "aws_iam_role" "aws_load_balancer_controller" {
  name = "aws-load-balancer-controller"
}

resource "kubernetes_service_account_v1" "aws_load_balancer_controller" {
  metadata {
    namespace = "kube-system"
    name      = "aws-load-balancer-controller"

    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.aws_load_balancer_controller.arn
    }

    labels = {
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
  }
}