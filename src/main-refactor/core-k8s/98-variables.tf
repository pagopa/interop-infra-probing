variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "env" {
  type        = string
  default     = "dev"
  description = "Environment name"

  validation {
    condition     = var.env == "dev" || var.env == "uat" || var.env == "prod"
    error_message = "The env value must be either 'dev', 'uat' or 'prod'. No other values are allowed."
  }
}

variable "stage" {
  type        = string
  description = "Stage name"
}

variable "tags" {
  type = map(any)
  default = {
    CreatedBy = "Terraform"
  }
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "enable_fluentbit_process_logs" {
  type        = bool
  description = "Enables FluentBit process logs to help with debugging. WARNING: produces A LOT of logs and could significantly increase CloudWatch costs"
  default     = false
}

variable "container_logs_cloudwatch_retention_days" {
  type        = number
  description = "Set the retention period on CloudWatch (in days) for container logs"
}

variable "aws_lb_controller_role_name" {
  type        = string
  description = "Name of the IAM role to be assumed by the AWS Load Balancer Controller service account"
}

variable "aws_lb_controller_chart_version" {
  type        = string
  description = "Chart version for AWS Load Balancer Controller"
}

variable "aws_lb_controller_replicas" {
  type        = number
  description = "Replica count for AWS Load Balancer Controller"
}

variable "kube_state_metrics_image_version_tag" {
  type        = string
  description = "Image version tag of Kube State Metrics"
}

variable "kube_state_metrics_cpu" {
  type        = string
  description = "CPU resource for Kube State Metrics"
}

variable "kube_state_metrics_memory" {
  type        = string
  description = "Memory resource for Kube State Metrics"
}

variable "adot_collector_role_name" {
  type        = string
  description = "Name of the IAM role to be assumed by the ADOT service account"
}

variable "adot_collector_image_uri" {
  type        = string
  description = "Docker image URI for the ADOT collector"
}

variable "adot_collector_cpu" {
  type        = string
  description = "CPU resource for the ADOT collector"
}

variable "adot_collector_memory" {
  type        = string
  description = "Memory resource for the ADOT collector"
}

variable "keda_chart_version" {
  type        = string
  description = "KEDA Helm Chart version"
  default     = null
}

variable "keda_operator_cpu" {
  type        = string
  description = "KEDA Operator CPU resources limits"
  default     = "250m"
}

variable "keda_operator_memory" {
  type        = string
  description = "KEDA Operator RAM resources limits"
  default     = "250Mi"
}

variable "keda_webhooks_cpu" {
  type        = string
  description = "KEDA Admission Webhooks CPU resources limits"
  default     = "250m"
}

variable "keda_webhooks_memory" {
  type        = string
  description = "KEDA Admission Webhooks RAM resources limits"
  default     = "250Mi"
}

variable "keda_metrics_server_cpu" {
  type        = string
  description = "KEDA Metrics Server CPU resources limits"
  default     = "250m"
}

variable "keda_metrics_server_memory" {
  type        = string
  description = "KEDA Metrics Server RAM resources limits"
  default     = "250Mi"
}
