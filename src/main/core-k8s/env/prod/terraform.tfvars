aws_region = "eu-south-1"
env        = "prod"

stages_to_provision = ["prod"]

tags = {
  Account     = "pdnd-probing-prod"
  Layer       = "core-k8s"
  Environment = "prod"
  CreatedBy   = "Terraform"
  Owner       = "PagoPA"
  Source      = "https://github.com/pagopa/interop-infra-probing"
}

eks_cluster_name = "probing-eks-cluster-prod"

enable_fluentbit_process_logs            = false
container_logs_cloudwatch_retention_days = 365

aws_lb_controller_role_name     = "aws-load-balancer-controller-prod"
aws_lb_controller_chart_version = "1.14.1"
aws_lb_controller_replicas      = 2

kube_state_metrics_helm_chart_version = "6.4.1"
kube_state_metrics_image_version_tag  = "v2.12.0"
kube_state_metrics_cpu                = "500m"
kube_state_metrics_memory             = "512Mi"

adot_collector_role_name = "adot-collector-prod"
adot_collector_image_uri = "amazon/aws-otel-collector:v0.30.0"
adot_collector_cpu       = "2"
adot_collector_memory    = "2Gi"

keda_chart_version         = "2.17.0"
keda_operator_cpu          = "500m"
keda_operator_memory       = "1Gi"
keda_webhooks_cpu          = "250m"
keda_webhooks_memory       = "250Mi"
keda_metrics_server_cpu    = "500m"
keda_metrics_server_memory = "1Gi"
