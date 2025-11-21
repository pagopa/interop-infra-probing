data "aws_vpc" "probing" {
  id = var.vpc_id
}

data "aws_eks_cluster" "probing" {
  name = var.eks_cluster_name
}

data "aws_iam_openid_connect_provider" "probing_eks" {
  url = data.aws_eks_cluster.probing.identity[0].oidc[0].issuer
}

data "aws_rds_cluster" "probing_operational_database" {
  cluster_identifier = var.probing_operational_database_cluster_identifier
}

data "aws_subnets" "probing_int_lbs" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.probing.id]
  }

  filter {
    name   = "cidr-block"
    values = toset(var.int_lbs_cidrs)
  }
}

data "aws_route53_zone" "probing_base" {
  name         = var.probing_base_route53_zone_name
  private_zone = false
}
