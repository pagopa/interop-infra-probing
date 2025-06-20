data "aws_subnets" "vpn" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }

  filter {
    name   = "cidr-block"
    values = toset(local.vpn_cidrs)
  }
}

# this is the imported certificate from the private CA, used for mutual authentication
data "aws_acm_certificate" "vpn" {
  count = var.env != "prod" ? 1 : 0

  # domain = format("vpn.%s", var.dns_probing_base_domain)
  domain = format("vpn.%s.probing.interop.pagopa.it", var.env) #TODO: edit to 'stato-eservice' instead of 'probing' when certificate is ready
}

# TODO
# resource "aws_iam_saml_provider" "vpn" {
#   count = var.env == "prod" ? 1 : 0
#
#   name                   = format("interop-vpn-saml-%s", var.env)
#   saml_metadata_document = file(var.vpn_saml_metadata_path)
# }

resource "aws_cloudwatch_log_group" "vpn" {
  name = format("/aws/client-vpn/%s-vpn-%s/connections", local.project, var.env)

  retention_in_days = var.env == "prod" ? 90 : 30
  skip_destroy      = true
}

resource "aws_security_group" "vpn_clients" {
  name        = format("client-vpn/%s-vpn-%s", local.project, var.env)
  description = "SG for VPN clients"
  vpc_id      = module.vpc.vpc_id

  egress {
    description      = ""
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [module.vpc.vpc_cidr_block]
    ipv6_cidr_blocks = []
    security_groups  = []
  }
}

locals {
  vpc_ip_no_cidr = (split("/", module.vpc.vpc_cidr_block))[0]
  vpc_dns_server = replace(local.vpc_ip_no_cidr, "/.0$/", ".2")
}

resource "aws_ec2_client_vpn_endpoint" "vpn" {
  description = format("%s-vpn-%s", local.project, var.env)
  # TODO
  # server_certificate_arn = var.env == "prod" ? aws_acm_certificate.vpn[0].arn : data.aws_acm_certificate.vpn[0].arn
  server_certificate_arn = data.aws_acm_certificate.vpn[0].arn
  client_cidr_block      = "10.2.0.0/22" # avoid overlap with VPC and EKS' "cluster_service_ipv4_cidr"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [aws_security_group.vpn_clients.id]

  split_tunnel = true
  dns_servers  = [local.vpc_dns_server]

  session_timeout_hours = 10

  # TODO
  # dynamic "authentication_options" {
  #   for_each = var.env == "prod" ? [1] : []
  #
  #   content {
  #     type              = "federated-authentication"
  #     saml_provider_arn = aws_iam_saml_provider.vpn[0].arn
  #   }
  # }

  dynamic "authentication_options" {
    for_each = var.env != "prod" ? [1] : []

    content {
      type                       = "certificate-authentication"
      root_certificate_chain_arn = data.aws_acm_certificate.vpn[0].arn
    }
  }

  connection_log_options {
    enabled              = true
    cloudwatch_log_group = aws_cloudwatch_log_group.vpn.name
  }

  tags = {
    Name = format("%s-vpn-%s", local.project, var.env)
  }
}

resource "aws_ec2_client_vpn_network_association" "vpn_subnets" {
  # multi-az only for prod
  for_each = toset(var.env == "prod" ? data.aws_subnets.vpn.ids : [data.aws_subnets.vpn.ids[0]])

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  subnet_id              = each.value
}

resource "aws_ec2_client_vpn_authorization_rule" "vpc_only" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  target_network_cidr    = module.vpc.vpc_cidr_block
  authorize_all_groups   = true
}

