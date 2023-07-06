resource "aws_cloudwatch_dashboard" "pod_metrics" {
  for_each       = toset(local.microservices)
  dashboard_name = "${each.value}-pod-metrics-${var.env}"

  dashboard_body = templatefile("${path.module}/assets/cloudwatch/pod_metric_dashboard.json.tftpl", {
    microservice = each.value, cluster_name = module.eks.cluster_name, k8s_namespace = var.env, aws_region = var.aws_region
  })
}