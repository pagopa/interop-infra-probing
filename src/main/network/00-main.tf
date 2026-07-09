terraform {
  required_version = "~> 1.15.7"

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.53.0"
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
  project = "probing"
}
