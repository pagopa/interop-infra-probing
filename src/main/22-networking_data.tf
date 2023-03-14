data "aws_subnets" "control_plane" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }

  filter {
    name   = "cidr-block"
    values = toset(var.eks_control_plane_subnets)
  }
}

data "aws_subnets" "workload" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }

  filter {
    name   = "cidr-block"
    values = toset(var.eks_workload_subnets)
  }
}