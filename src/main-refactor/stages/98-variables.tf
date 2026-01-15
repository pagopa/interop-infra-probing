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

variable "azs" {
  type        = list(string)
  description = "Availability zones to use"
}

variable "tags" {
  type = map(any)
  default = {
    CreatedBy = "Terraform"
  }
}

variable "sso_admin_role_name" {
  type        = string
  description = "Name of the SSO admin role"
}

variable "vpc_id" {
  type        = string
  description = "ID of the probing VPC"
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the probing EKS cluster"
}

variable "interop_msk_cluster_arn" {
  description = "ARN of the Interop MSK cluster"
  type        = string
  default     = null
}

variable "probing_operational_database_cluster_identifier" {
  type        = string
  description = "Cluster identifier of the Probing operational database"
}

variable "probing_operational_database_name" {
  type        = string
  description = "Name of the Probing operational database for the current stage"
}

variable "int_lbs_cidrs" {
  type        = list(string)
  description = "CIDRs of probing internal Load balancers subnets"
}

variable "probing_base_route53_zone_name" {
  description = "Name of Route 53 Zone for Probing base DNS domain"
  type        = string
}

variable "fe_base_url" {
  type        = string
  description = "Base URL of FE page"
}

variable "backend_microservices_port" {
  description = "Port on which the backend microservices listen"
  type        = number
}

variable "probing_openapi_path" {
  description = "Relative path of Probing OpenAPI definition file"
  type        = string
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

variable "timestream_instance_name" {
  type        = string
  description = "Name of the Timestream for InfluxDB instance"
}

variable "timestream_instance_port" {
  type        = string
  description = "Port of the Timestream for InfluxDB instance"
}

variable "timestream_instance_id" {
  type        = string
  description = "ID of the Timestream for InfluxDB instance"
}

variable "timestream_instance_endpoint" {
  type        = string
  description = "Endpoint of the Timestream for InfluxDB instance"
}

variable "timestream_instance_organization" {
  type        = string
  description = "Organization name in the Timestream for InfluxDB instance"
}

variable "timestream_instance_bucket_name" {
  type        = string
  description = "Name of the bucket in the Timestream for InfluxDB instance"
}

variable "probing_analytics_admin_secret_name" {
  type        = string
  description = "Name of the SM secret for the admin user in the Timestream for InfluxDB instance"
}

variable "probing_deployment_github_repo_role_name" {
  description = "Name of the probing deployment-github-repo IAM role"
  type        = string
}

variable "eks_application_log_group_name" {
  description = "Name of the application log group created by FluentBit"
  type        = string
  default     = null
}