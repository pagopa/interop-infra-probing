variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "app_name" {
  type        = string
  description = "App name."
}

variable "be_prefix" {
  type        = string
  description = "Backend name prefix"
}

variable "env" {
  type        = string
  default     = "dev"
  description = "Environment name"
}

variable "sso_admin_role_name" {
  type        = string
  description = "Name of the SSO admin role"
}

variable "interop_probing_bucket_arn" {
  type        = string
  description = "ARN of existing bucket name for probing list"
}

variable "frontend_github_repo" {
  type        = string
  description = "Name of the probing frontend Github repo (format: 'organization/repo-name')"
  default     = "pagopa/interop-fe-probing"
}

variable "fe_base_url" {
  type        = string
  description = "Base URL of FE page"
}

variable "k8s_github_repo" {
  type        = string
  description = "Name of the probing K8s Github repo (format: 'organization/repo-name')"
  default     = "pagopa/interop-probing-k8s"
}

variable "database_subnets" {
  type        = list(string)
  description = "Database dedicated private subnets"
}

variable "eks_control_plane_subnets" {
  type        = list(string)
  description = "EKS Control Plane dedicated private subnets"
}

variable "eks_workload_subnets" {
  type        = list(string)
  description = "EKS Workload dedicated private subnets"
}

variable "app_public_subnets" {
  type        = list(string)
  description = "Application VPC public subnets"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version to use"
}

variable "bastion_host_ami" {
  type        = string
  description = "Bastion host AMI"
}

variable "bastion_host_instance_type" {
  type        = string
  description = "Bastion host instance type"
}

variable "bastion_host_key_pair_name" {
  type        = string
  description = "Bastion host key pair name"
}

variable "analytics_database_name" {
  type        = string
  description = "Analytics database name"
}

variable "operational_database_name" {
  type        = string
  description = "Operational database name"
}

variable "operational_database_name_master_user" {
  type        = string
  description = "Operational database master username"
}

variable "database_scaling_min_capacity" {
  type        = number
  description = "Operational database scaling configuration minimum capacity"
}
variable "database_scaling_max_capacity" {
  type        = number
  description = "Operational database scaling configuration maximum capacity"
}

variable "kubernetes_addons_versions" {
  type        = map(any)
  description = "Kuberntes addons version"
}

variable "alb_ingress_group" {
  type        = string
  description = "Name of the ALB ingress group"
}

variable "api_version" {
  type        = string
  description = "Version of the API definition in openapi"
}

variable "openapi_spec_path" {
  type        = string
  description = "The relative path in the repo for open api specification"
}

variable "timestream_table_magnetic_store_retention_period_in_days" {
  type        = number
  description = "How long data stays in magnetic store in days"
}

variable "timestream_table_memory_store_retention_period_in_hours" {
  type        = number
  description = "How long data stays in memory store in hours"
}

variable "probing_env_domain_name" {
  type        = string
  description = "Base domain for the probing project in this environment (e.g. foo.dev.bar.com)"
}

variable "cw_alarm_thresholds" {
  type        = map(any)
  description = "Clouwatch alarms threshold"
}


variable "jwks_uri" {
  type        = string
  description = "Well knows jwks URI for PDND call to APIGW"
}


variable "lambda_authorizer_cache_enabled" {
  type        = bool
  description = "Whether the cache is enabled for JWKS in lambda authorizer"
  default     = true
}

variable "lambda_authorizer_cache_max_age" {
  type        = number
  description = "Max age for cache JWKS in lambda authorizer"
  default     = 86400
}

variable "tags" {
  type = map(any)
  default = {
    CreatedBy = "Terraform"
  }
}
