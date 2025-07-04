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

variable "azs" {
  type        = list(string)
  description = "Availability zones to use"
}

variable "stages_to_provision" {
  type        = list(string)
  default     = []
  description = "Stages to provision in the environment (e.g. in the dev environment, the stages to be provisioned are: dev, qa, vapt)"
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

variable "eks_workload_cidrs" {
  type        = list(string)
  description = "CIDRs of the subnets reserved to EKS workload"
}

variable "eks_control_plane_cidrs" {
  type        = list(string)
  description = "CIDRs of the subnets reserved to EKS Control Plane"
}

variable "aurora_cidrs" {
  type        = list(string)
  description = "CIDRs of the subnets reserved to Aurora"
}

variable "msk_cidrs" {
  type        = list(string)
  description = "CIDRs of the subnets reserved to MSK"
}

variable "timestream_cidrs" {
  type        = list(string)
  description = "CIDRs of the subnets reserved to Timestream for InfluxDB instances"
}

variable "vpn_clients_security_group_id" {
  type        = string
  description = "ID of the Security Groups associated to the VPN"
}

variable "interop_msk_clusters_arns" {
  description = "ARNs of the Interop MSK clusters to which it's necessary to establish a VPC connection"
  type        = map(any)
}

variable "probing_analytics_database_name" {
  type        = string
  description = "Probing analytics database name"
}

variable "probing_operational_database_prefix_name" {
  type        = string
  description = "Prefix for the Probing operational database name"
}

variable "probing_operational_database_master_username" {
  type        = string
  description = "Probing operational database master username"
}

variable "probing_operational_database_engine_version" {
  type        = string
  description = "Probing operational database PostgreSQL engine version"
}

variable "probing_operational_database_instance_class" {
  description = "Aurora instance class for Probing Operational Database cluster"
  type        = string
}

variable "probing_operational_database_number_instances" {
  description = "Number of instances of the Probing Operational Database cluster"
  type        = number

  validation {
    condition     = var.probing_operational_database_number_instances > 0
    error_message = "The number of instances must be greater than 0"
  }
}

variable "probing_operational_database_ca_cert_id" {
  description = "Certificate Authority ID for Probing Operational Database cluster"
  type        = string
}

variable "probing_operational_database_param_group_family" {
  description = "Probing Operational Database cluster parameter group family"
  type        = string
}

variable "eks_k8s_version" {
  type        = string
  description = "K8s version used in the EKS cluster"
}

variable "eks_vpc_cni_version" {
  type        = string
  description = "EKS vpc-cni addon version"
  default     = null
}

variable "eks_coredns_version" {
  type        = string
  description = "EKS coredns addon version"
  default     = null
}

variable "eks_kube_proxy_version" {
  type        = string
  description = "EKS kube-proxy addon version"
  default     = null
}

variable "backend_microservices_port" {
  description = "Port on which the backend microservices listen"
  type        = number
}

variable "project_monorepo_name" {
  description = "Project monorepo name (format: organization/repo-name)."
  type        = string
}

variable "github_runners_allowed_repos" {
  description = "Github repositories names (format: organization/repo-name) allowed to assume the ECS role to start/stop self-hosted runners"
  type        = list(string)
}

variable "github_runners_cpu" {
  description = "vCPU to allocate for each GH runner execution (e.g. 1024)"
  type        = number
}

variable "github_runners_memory" {
  description = "RAM to allocate for each GH runner execution (e.g. 2048)"
  type        = number
}

variable "github_runners_image_uri" {
  description = "URI of the runner image"
  type        = string
}

variable "deployment_repo_name" {
  description = "Github repository name containing deployment automation"
  type        = string
}
