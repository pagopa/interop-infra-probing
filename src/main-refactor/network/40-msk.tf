data "aws_subnets" "msk" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }

  filter {
    name   = "cidr-block"
    values = toset(local.msk_cidrs)
  }
}

resource "aws_security_group" "interop_msk_vpc_connection" {
  count = local.deploy_interop_msk_integration ? 1 : 0

  description = "MSK cross-account VPC connection for Interop platform-events-${var.env} cluster"
  name        = "msk/interop-platform-events-${var.env}"

  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Clients inside VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    security_groups = [
      data.aws_eks_cluster.probing[0].vpc_config[0].cluster_security_group_id,
      aws_security_group.vpn_clients.id
    ]
  }

  egress {
    description = "Remote MSK cluster"
    from_port   = 14001
    to_port     = 14100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #TODO: can we get an exact range? It depends on PrivateLink
  }
}

resource "aws_msk_vpc_connection" "interop_msk_cluster" {
  count = local.deploy_interop_msk_integration ? 1 : 0

  authentication     = "SASL_IAM"
  target_cluster_arn = var.interop_msk_cluster_arn

  vpc_id          = module.vpc.vpc_id
  client_subnets  = data.aws_subnets.msk.ids
  security_groups = [aws_security_group.interop_msk_vpc_connection[0].id]
}
