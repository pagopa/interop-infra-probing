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

variable "be_prefix" {
  description = "Name prefix used by backend apps"
  type        = string
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "fargate_profiles_roles_names" {
  type        = list(string)
  description = "Names of the Fargate profiles roles"
}

variable "sso_full_admin_role_name" {
  type        = string
  description = "Name of the SSO 'FullAdmin' role"
}

variable "iam_users_k8s_admin" {
  type        = list(string)
  description = "IAM users to be granted admin access in the cluster"
  default     = []
}
