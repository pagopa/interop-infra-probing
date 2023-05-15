resource "aws_route53_record" "probing_distribution" {
  provider = aws.us_east_1

  name    = var.probing_env_domain_name
  type    = "A"
  zone_id = aws_route53_zone.probing_public.zone_id

  alias {
    evaluate_target_health = true
    name                   = module.fe_cdn.cloudfront_distribution_domain_name
    zone_id                = "Z2FDTNDATAQYW2" # fixed value for CloudFront distributions
  }
}

resource "aws_route53_record" "probing_distribution_www" {
  provider = aws.us_east_1

  name    = format("www.%s", var.probing_env_domain_name)
  type    = "A"
  zone_id = aws_route53_zone.probing_public.zone_id

  alias {
    evaluate_target_health = true
    name                   = module.fe_cdn.cloudfront_distribution_domain_name
    zone_id                = "Z2FDTNDATAQYW2" # fixed value for CloudFront distributions
  }
}


resource "aws_acm_certificate" "probing_distribution" {
  provider = aws.us_east_1

  domain_name       = var.probing_env_domain_name
  validation_method = "DNS"

  subject_alternative_names = [format("www.%s", var.probing_env_domain_name)]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "probing_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.probing_distribution.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  records = [each.value.record]
  type    = each.value.type
  zone_id = aws_route53_zone.probing_public.zone_id
  ttl     = 300
}

resource "aws_acm_certificate_validation" "probing_distribution" {
  provider = aws.us_east_1

  certificate_arn         = aws_acm_certificate.probing_distribution.arn
  validation_record_fqdns = [for record in aws_route53_record.probing_cert_validation : record.fqdn]
}

