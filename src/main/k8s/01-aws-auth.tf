data "aws_iam_role" "sso_full_admin" {
  name = var.sso_full_admin_role_name
}

resource "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<ROLES
      - rolearn: "${data.aws_iam_role.sso_full_admin.arn}"
        username: "sso-fulladmin-{{SessionName}}"
        groups: "system:masters"
    ROLES
  }
}
