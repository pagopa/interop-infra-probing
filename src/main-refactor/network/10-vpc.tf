locals {
  eks_control_plane_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  eks_workload_cidrs      = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  aurora_cidrs            = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
  egress_cidrs            = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  vpce_cidrs              = ["10.0.13.0/24", "10.0.14.0/24", "10.0.15.0/24"]
  vpn_cidrs               = ["10.0.16.0/24", "10.0.17.0/24", "10.0.18.0/24"]
  msk_cidrs               = ["10.0.19.0/24", "10.0.20.0/24", "10.0.21.0/24"]

  eks_control_plane_subnets_names = [for idx, subn in local.eks_control_plane_cidrs :
  format("%s-eks-cp-%d-%s", local.project, idx + 1, var.env)]

  eks_workload_subnets_names = [for idx, subn in local.eks_workload_cidrs :
  format("%s-eks-workload-%d-%s", local.project, idx + 1, var.env)]

  aurora_subnets_names = [for idx, subn in local.aurora_cidrs :
  format("%s-aurora-%d-%s", local.project, idx + 1, var.env)]

  egress_subnets_names = [for idx, subn in local.egress_cidrs :
  format("%s-egress-%d-%s", local.project, idx + 1, var.env)]

  vpce_subnets_names = [for idx, subn in local.vpce_cidrs :
  format("%s-vpce-%d-%s", local.project, idx + 1, var.env)]

  vpn_subnets_names = [for idx, subn in local.vpn_cidrs :
  format("%s-vpn-%d-%s", local.project, idx + 1, var.env)]

  msk_subnets_names = [for idx, subn in local.msk_cidrs :
  format("%s-msk-%d-%s", local.project, idx + 1, var.env)]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = format("%s-vpc-%s", local.project, var.env)
  cidr = "10.0.0.0/16"
  azs  = var.azs

  enable_dns_hostnames = true
  enable_dns_support   = true

  create_igw              = true
  map_public_ip_on_launch = false

  enable_nat_gateway = true
  single_nat_gateway = false
  # This will create N instances of NAT (N = #AZs) in the first N public subnets specified in 'public_subnets'
  one_nat_gateway_per_az = true

  # Order matters: the first N subnets (N = #AZs) will host a NAT instance. See 'one_nat_gateway_per_az'
  public_subnets      = local.egress_cidrs
  public_subnet_names = local.egress_subnets_names

  private_subnets      = local.eks_workload_cidrs
  private_subnet_names = local.eks_workload_subnets_names

  intra_subnets = concat(
    local.eks_control_plane_cidrs,
    local.vpce_cidrs,
    local.vpn_cidrs,
    local.msk_cidrs,
  )
  intra_subnet_names = concat(
    local.eks_control_plane_subnets_names,
    local.vpce_subnets_names,
    local.vpn_subnets_names,
    local.msk_subnets_names
  )

  create_database_subnet_group       = false
  create_database_subnet_route_table = true
  create_database_nat_gateway_route  = false

  database_subnets      = local.aurora_cidrs
  database_subnet_names = local.aurora_subnets_names

  enable_flow_log = false
}
