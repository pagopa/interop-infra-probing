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

variable "database_min_capacity" {
  type        = number
  description = "Database autoscaling minimum capacity"
}

variable "database_max_capacity" {
  type        = number
  description = "Database autoscaling maximum capacity"
}


variable "tags" {
  type = map(any)
  default = {
    CreatedBy = "Terraform"
  }
}
