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

variable "probing_analytics_database_name" {
  type        = string
  description = "Name of the Probing analytics database"
}

variable "timestream_table_magnetic_store_retention_period_in_days" {
  type        = number
  description = "How long data stays in magnetic store in days"
}

variable "timestream_table_memory_store_retention_period_in_hours" {
  type        = number
  description = "How long data stays in memory store in hours"
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

###

# variable "interop_probing_bucket_arn" {
#   type        = string
#   description = "ARN of existing bucket name for probing list"
# }

# variable "frontend_github_repo" {
#   type        = string
#   description = "Name of the probing frontend Github repo (format: 'organization/repo-name')"
#   default     = "pagopa/interop-probing-core"
# }



# variable "k8s_github_repo" {
#   type        = string
#   description = "Name of the probing K8s Github repo (format: 'organization/repo-name')"
#   default     = "pagopa/interop-probing-k8s"
# }


# variable "bastion_host_ami" {
#   type        = string
#   description = "Bastion host AMI"
# }

# variable "bastion_host_instance_type" {
#   type        = string
#   description = "Bastion host instance type"
# }

# variable "bastion_host_key_pair_name" {
#   type        = string
#   description = "Bastion host key pair name"
# }

# variable "analytics_database_name" {
#   type        = string
#   description = "Analytics database name"
# }

# variable "database_scaling_min_capacity" {
#   type        = number
#   description = "Operational database scaling configuration minimum capacity"
# }
# variable "database_scaling_max_capacity" {
#   type        = number
#   description = "Operational database scaling configuration maximum capacity"
# }

# variable "kubernetes_addons_versions" {
#   type        = map(any)
#   description = "Kuberntes addons version"
# }

# variable "alb_ingress_group" {
#   type        = string
#   description = "Name of the ALB ingress group"
# }

# variable "api_version" {
#   type        = string
#   description = "Version of the API definition in openapi"
# }

# variable "openapi_spec_path" {
#   type        = string
#   description = "The relative path in the repo for open api specification"
# }

# variable "cw_alarm_thresholds" {
#   type        = map(any)
#   description = "Clouwatch alarms threshold"
# }

# variable "jwks_uri" {
#   type        = string
#   description = "Well knows jwks URI for PDND call to APIGW"
# }

# variable "lambda_authorizer_cache_enabled" {
#   type        = bool
#   description = "Whether the cache is enabled for JWKS in lambda authorizer"
#   default     = true
# }

# variable "lambda_authorizer_cache_max_age" {
#   type        = number
#   description = "Max age for cache JWKS in lambda authorizer"
#   default     = 86400
# }
