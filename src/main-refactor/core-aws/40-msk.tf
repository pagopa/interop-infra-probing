data "aws_subnets" "msk" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.probing.id]
  }

  filter {
    name   = "cidr-block"
    values = toset(var.msk_cidrs)
  }
}

resource "aws_security_group" "interop_msk_vpc_connection" {
  for_each = local.deploy_interop_msk_integration ? var.interop_msk_clusters_arns : {}

  description = "MSK cross-account VPC connection for Interop platform-events-${each.key} cluster"
  name        = "msk/interop-platform-events-${each.key}"

  vpc_id = data.aws_vpc.probing.id

  ingress {
    description = "Clients inside VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    security_groups = [
      module.eks.cluster_primary_security_group_id,
      data.aws_security_group.vpn_clients.id
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
  for_each = local.deploy_interop_msk_integration ? var.interop_msk_clusters_arns : {}

  authentication     = "SASL_IAM"
  target_cluster_arn = each.value

  vpc_id          = data.aws_vpc.probing.id
  client_subnets  = data.aws_subnets.msk.ids
  security_groups = [aws_security_group.interop_msk_vpc_connection[each.key].id]
}
