resource "kubernetes_manifest" "adot_collector" {
  for_each = fileset("${path.module}/assets/adot_collector/", "*.yaml")

  manifest = yamldecode(templatefile("${path.module}/assets/adot_collector/${each.value}", {
    cluster_name           = var.eks_cluster_name
    namespace              = "aws-observability"
    aws_region             = var.aws_region
    aws_role_arn           = var.adot_irsa_role_arn
    adot_collector_img_tag = var.adot_collector_img_tag
  }))
  field_manager {
    force_conflicts = true
  }

}