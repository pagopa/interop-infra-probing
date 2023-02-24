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


variable "tags" {
  type = map(any)
  default = {
    CreatedBy = "Terraform"
  }
}
