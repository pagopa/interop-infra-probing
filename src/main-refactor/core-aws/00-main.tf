terraform {
  required_version = "~> 1.8.0"

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }

  # avoid drift between VPC module and K8s tags applied only for some specific subnets
  ignore_tags {
    key_prefixes = ["kubernetes.io/role/elb", "kubernetes.io/role/internal-elb"]
  }
}

locals {
  project                        = "probing"
  deploy_interop_msk_integration = var.interop_msk_clusters_arns != null
  deploy_keda                    = var.env == "dev"
}

data "aws_caller_identity" "current" {}

data "aws_iam_role" "sso_admin" {
  name = var.sso_admin_role_name
}
