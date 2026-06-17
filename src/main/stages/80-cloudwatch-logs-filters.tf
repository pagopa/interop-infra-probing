data "aws_cloudwatch_log_group" "eks_application" {
  name = var.eks_application_log_group_name
}

resource "aws_cloudwatch_log_metric_filter" "eks_app_logs_errors" {
  name           = format("eks-application-logs-errors-%s", var.stage)
  pattern        = "{ $.log = \"*ERROR*\" || $.stream = \"stderr\" }"
  log_group_name = data.aws_cloudwatch_log_group.eks_application.name

  metric_transformation {
    name      = "ErrorCount"
    namespace = "EKSApplicationLogsFilters"
    value     = "1"

    dimensions = {
      PodApp       = "$.pod_app"
      PodNamespace = "$.pod_namespace"
    }
  }
}
