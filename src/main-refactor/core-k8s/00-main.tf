terraform {
  required_version = "~> 1.8.0"

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13.2"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.probing.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.probing.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.probing.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.probing.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.probing.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.probing.token
  }
}

data "aws_caller_identity" "current" {}

locals {
  project     = "probing"
  deploy_keda = var.stage == "dev"
}
