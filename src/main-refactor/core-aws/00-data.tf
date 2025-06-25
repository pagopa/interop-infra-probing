data "aws_vpc" "probing" {
  id = var.vpc_id
}

data "aws_subnets" "aurora_probing_operational_store" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.probing.id]
  }

  filter {
    name   = "cidr-block"
    values = toset(var.aurora_cidrs)
  }
}

data "aws_subnets" "eks_control_plane" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.probing.id]
  }

  filter {
    name   = "cidr-block"
    values = toset(var.eks_control_plane_cidrs)
  }
}

data "aws_subnets" "eks_workload" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.probing.id]
  }

  filter {
    name   = "cidr-block"
    values = toset(var.eks_workload_cidrs)
  }
}

data "aws_security_group" "vpn_clients" {
  id = var.vpn_clients_security_group_id
}
