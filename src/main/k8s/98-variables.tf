variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "app_name" {
  type        = string
  description = "App name."
}

variable "env" {
  type        = string
  default     = "dev"
  description = "Environment name"
}

variable "tags" {
  type = map(any)
  default = {
    CreatedBy = "Terraform"
  }
}

variable "eks_cluster_name" {
  type = string
  description = "Name of the EKS cluster"
}

variable "sso_full_admin_role_name" {
  type = string
  description = "Name of the SSO 'FullAdmin' role"
}
