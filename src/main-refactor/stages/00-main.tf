terraform {
  required_version = "~> 1.8.0"

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
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

provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"

  default_tags {
    tags = var.tags
  }
}

locals {
  project                        = "probing"
  app_name                       = format("interop-%s", local.project)
  terraform_state                = "stages"
  use_postgresql_user_module     = var.stage == "dev" || var.stage == "qa" || var.stage == "uat"
  deploy_interop_msk_integration = var.interop_msk_cluster_arn != null
}

data "aws_caller_identity" "current" {}
