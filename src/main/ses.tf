resource "aws_sesv2_configuration_set" "stato_eservice" {
  configuration_set_name = format("stato-eservice-%s", var.env)

  delivery_options {
    tls_policy = "REQUIRE"
  }

  reputation_options {
    reputation_metrics_enabled = true
  }
}

resource "aws_sesv2_email_identity" "stato_eservice" {
  email_identity         = aws_route53_zone.probing_public.name
  configuration_set_name = aws_sesv2_configuration_set.stato_eservice.configuration_set_name

  dkim_signing_attributes {
    next_signing_key_length = "RSA_2048_BIT"
  }
}

locals {
  stato_eservice_dkim_tokens = aws_sesv2_email_identity.stato_eservice.dkim_signing_attributes[0].tokens
}

resource "aws_route53_record" "stato_eservice_dkim" {
  count   = 3

  zone_id = aws_route53_zone.probing_public.zone_id
  name    = "${local.stato_eservice_dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${local.stato_eservice_dkim_tokens[count.index]}.dkim.amazonses.com"]
}

resource "aws_sesv2_email_identity_mail_from_attributes" "stato_eservice" {
  email_identity = aws_sesv2_email_identity.stato_eservice.email_identity

  behavior_on_mx_failure = "REJECT_MESSAGE"
  mail_from_domain       = "mail.${aws_sesv2_email_identity.stato_eservice.email_identity}"
}

resource "aws_route53_record" "stato_eservice_mx" {
  zone_id = aws_route53_zone.probing_public.zone_id
  name    = aws_sesv2_email_identity_mail_from_attributes.stato_eservice.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${var.aws_region}.amazonses.com"]
}

resource "aws_route53_record" "stato_eservice_spf" {
  zone_id = aws_route53_zone.probing_public.zone_id
  name    = aws_sesv2_email_identity_mail_from_attributes.stato_eservice.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}
