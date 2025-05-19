variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "env" {
  type        = string
  default     = "dev"
  description = "Environment name"
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

variable "interop_msk_cluster_arn" {
  description = "ARN of the Interop MSK cluster"
  type        = string
  default     = null
}

variable "dns_probing_base_domain" {
  description = "Base DNS domain for the Probing product"
  type        = string
}

variable "dns_probing_dev_ns_records" {
  description = "NS records for Probing 'dev' hosted zone. Used to grant DNS delegation for the subdomain"
  type        = list(string)
  default     = []
}

variable "dns_probing_qa_ns_records" {
  description = "NS records for Probing 'qa' hosted zone. Used to grant DNS delegation for the subdomain"
  type        = list(string)
  default     = []
}

variable "dns_probing_vapt_ns_records" {
  description = "NS records for Probing 'vapt' hosted zone. Used to grant DNS delegation for the subdomain"
  type        = list(string)
  default     = []
}

variable "dns_probing_uat_ns_records" {
  description = "NS records for Probing 'uat' hosted zone. Used to grant DNS delegation for the subdomain"
  type        = list(string)
  default     = []
}

variable "dns_probing_att_ns_records" {
  description = "NS records for Probing 'att' hosted zone. Used to grant DNS delegation for the subdomain"
  type        = list(string)
  default     = []
}