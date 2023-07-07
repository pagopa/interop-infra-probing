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
