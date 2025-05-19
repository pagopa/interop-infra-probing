locals {
  delegate_probing_dev_subdomain  = var.env == "prod" && length(toset(var.dns_probing_dev_ns_records)) > 0
  delegate_probing_qa_subdomain   = var.env == "prod" && length(toset(var.dns_probing_qa_ns_records)) > 0
  delegate_probing_vapt_subdomain = var.env == "prod" && length(toset(var.dns_probing_vapt_ns_records)) > 0
}

resource "aws_route53_zone" "probing_public" {
  name = var.dns_probing_base_domain
}

resource "aws_route53_record" "probing_dev_delegation" {
  count = local.delegate_probing_dev_subdomain ? 1 : 0

  zone_id = aws_route53_zone.probing_public.zone_id
  name    = format("dev.%s", var.dns_probing_base_domain)
  type    = "NS"
  records = toset(var.dns_probing_dev_ns_records)
  ttl     = "300"
}

resource "aws_route53_record" "probing_qa_delegation" {
  count = local.delegate_probing_qa_subdomain ? 1 : 0

  zone_id = aws_route53_zone.probing_public.zone_id
  name    = format("qa.%s", var.dns_probing_base_domain)
  type    = "NS"
  records = toset(var.dns_probing_qa_ns_records)
  ttl     = "300"
}

resource "aws_route53_record" "probing_vapt_delegation" {
  count = local.delegate_probing_vapt_subdomain ? 1 : 0

  zone_id = aws_route53_zone.probing_public.zone_id
  name    = format("vapt.%s", var.dns_probing_base_domain)
  type    = "NS"
  records = toset(var.dns_probing_vapt_ns_records)
  ttl     = "300"
}
