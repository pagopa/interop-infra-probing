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
  deploy_interop_msk_integration = var.env != "qa" && var.interop_msk_cluster_arn != null
  terraform_state                = "network" #TOCHECK: Is this local necessary in the current state? It is used in the deployment-role's iam policy to grant him access only to the secrets that are managed by the deployment role to propagate such secrets in k8s. In this TF state, there are no secrets to be granted access for.
}

data "aws_caller_identity" "current" {}

data "aws_iam_role" "github_iac" {
  name = "GitHubActionIACRole"
}

data "aws_iam_role" "sso_admin" {
  name = var.sso_admin_role_name
}
