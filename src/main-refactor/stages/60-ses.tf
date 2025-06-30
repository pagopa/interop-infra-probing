module "probing_ses_identity" {
  #source = "git::https://github.com/pagopa/interop-infra-commons//terraform/modules/ses-identity?ref=v1.15.0"
  source = "./modules/ses-identity"

  env                           = var.stage
  ses_identity_name             = data.aws_route53_zone.probing_base.name #TOCHECK: Should we add a prefix?
  hosted_zone_id                = data.aws_route53_zone.probing_base.zone_id
  create_alarms                 = true
  sns_topics_arn                = [aws_sns_topic.platform_alarms.arn]
  ses_reputation_sns_topics_arn = [aws_sns_topic.platform_alarms.arn, aws_sns_topic.ses_reputation.arn]
}

module "probing_ses_iam_policy" {
  #source = "git::https://github.com/pagopa/interop-infra-commons//terraform/modules/ses-iam-policy?ref=v1.15.0"
  source = "./modules/ses-iam-policy"

  env                            = var.stage
  ses_iam_policy_name            = format("probing-ses-policy-%s", var.stage)
  ses_identity_arn               = module.probing_ses_identity.ses_identity_arn
  ses_configuration_set_arn      = module.probing_ses_identity.ses_configuration_set_arn
  allowed_recipients_regex       = ["*@pagopa.it"]                                                       #TOCHECK
  allowed_from_addresses_literal = [format("noreply@%s", module.probing_ses_identity.ses_identity_name)] #TOCHECK
}