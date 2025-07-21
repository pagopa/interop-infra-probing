resource "aws_wafv2_web_acl" "probing" {
  name  = format("%s-%s", local.project, var.stage)
  scope = "REGIONAL"

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "Probing-WebACL"
    sampled_requests_enabled   = false
  }

  default_action {
    allow {}
  }

  rule {
    name     = "Default"
    priority = 0

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "Probing-Default"
      sampled_requests_enabled   = false
    }

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          name = "NoUserAgent_HEADER"
          action_to_use {
            count {}
          }
        }
      }
    }
  }
}

resource "aws_wafv2_web_acl_association" "probing" {
  web_acl_arn  = aws_wafv2_web_acl.probing.arn
  resource_arn = aws_lb.probing.arn
}

resource "aws_cloudwatch_log_group" "probing_waf" {
  name = format("aws-waf-logs-%s-%s", local.project, var.stage)

  retention_in_days = var.env == "prod" ? 90 : 30
  skip_destroy      = true
}

resource "aws_wafv2_web_acl_logging_configuration" "probing" {
  resource_arn            = aws_wafv2_web_acl.probing.arn
  log_destination_configs = [aws_cloudwatch_log_group.probing_waf.arn]

  redacted_fields {
    single_header {
      name = "authorization"
    }
  }
}
