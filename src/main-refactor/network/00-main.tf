terraform {
  required_version = "~> 1.8.0"

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46.0"
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
  region = "eu-central-1"
  alias  = "ec1"

  default_tags {
    tags = var.tags
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
  deploy_interop_msk_integration = (var.env == "dev" || var.env == "uat" || var.env == "prod") && var.interop_msk_cluster_arn != null
}

data "aws_caller_identity" "current" {}

data "aws_iam_role" "github_iac" {
  name = "GitHubActionIACRole"
}

data "aws_iam_role" "sso_admin" {
  name = var.sso_admin_role_name
}
