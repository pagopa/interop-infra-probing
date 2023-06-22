resource "kubernetes_manifest" "adot_collector" {
  for_each = fileset("${path.module}/assets/adot_collector/", "*.yaml")

  manifest = yamldecode(templatefile("${path.module}/assets/adot_collector/${each.value}", {
    cluster_name = var.eks_cluster_name
    namespace    = "opentelemetry-operator-system"
    aws_region   = var.aws_region
    aws_role_arn = var.adot_irsa_role_arn
  }))
    field_manager {
    force_conflicts = true
  }

}