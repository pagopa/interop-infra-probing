# resource "aws_sesv2_configuration_set" "stato_eservice" {
#   configuration_set_name = format("stato-eservice-%s", var.env)
# }
#
# resource "aws_sesv2_email_identity" "stato_eservice" {
#   email_identity         = aws_route53_zone.probing_public.name
#   configuration_set_name = aws_sesv2_configuration_set.stato_eservice.configuration_set_name
#
#   dkim_signing_attributes {
#     next_signing_key_length = "RSA_2048_BIT"
#   }
# }

# resource "aws_ses_domain_identity" "stato_eservice" {
#   domain = aws_route53_zone.probing_public.name
# }
#
# resource "aws_ses_domain_dkim" "stato_eservice" {
#   domain = aws_ses_domain_identity.stato_eservice.domain
# }
#
# # DKIM also verifies domain ownership, no need for separate TXT records
# resource "aws_route53_record" "stato_eservice_dkim" {
#   count   = 3
#
#   zone_id = aws_route53_zone.probing_public.zone_id
#   name    = "${aws_ses_domain_dkim.stato_eservice.dkim_tokens[count.index]}._domainkey"
#   type    = "CNAME"
#   ttl     = "600"
#   records = ["${aws_ses_domain_dkim.stato_eservice.dkim_tokens[count.index]}.dkim.amazonses.com"]
# }
#
# resource "aws_ses_domain_mail_from" "stato_eservice" {
#   domain           = aws_ses_domain_identity.stato_eservice.domain
#   mail_from_domain = "mail.${aws_ses_domain_identity.stato_eservice.domain}"
# }
#
# resource "aws_route53_record" "stato_eservice_from_mx" {
#   zone_id = aws_route53_zone.probing_public.zone_id
#   name    = aws_ses_domain_mail_from.stato_eservice.mail_from_domain
#   type    = "MX"
#   ttl     = "600"
#   records = ["10 feedback-smtp.${var.aws_region}.amazonses.com"]
# }
#
# resource "aws_route53_record" "stato_eservice_from_txt" {
#   zone_id = aws_route53_zone.probing_public.zone_id
#   name    = aws_ses_domain_mail_from.stato_eservice.mail_from_domain
#   type    = "TXT"
#   ttl     = "600"
#   records = ["v=spf1 include:amazonses.com -all"]
# }
#
# resource "aws_ses_configuration_set" "stato_eservice" {
#   name = format("stato-eservice-%s", var.env)
#
#   reputation_metrics_enabled = true
#
#   delivery_options {
#     tls_policy = "Require"
#   }
# }
