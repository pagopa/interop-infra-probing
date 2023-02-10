terraform {
  required_version = "~> 1.3.6"

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.48.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.tags
  }
}

data "aws_caller_identity" "current" {}
