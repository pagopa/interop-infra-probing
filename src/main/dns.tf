resource "aws_route53_zone" "probing_public" {
  name = var.probing_env_domain_name
}
