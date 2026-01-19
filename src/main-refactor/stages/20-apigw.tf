resource "aws_cloudwatch_log_group" "apigw_access_logs" {
  name = format("amazon-apigateway-%s-access-logs-%s", local.project, var.stage)

  retention_in_days = var.stage == "prod" ? 365 : 90
  skip_destroy      = true
}

module "probing_apigw" {
  source = "git::https://github.com/pagopa/interop-infra-commons//terraform/modules/rest-apigw-openapi?ref=v1.31.0"

  maintenance_mode = false

  env                   = var.stage
  type                  = "generic"
  api_name              = "probing"
  openapi_relative_path = var.probing_openapi_path

  openapi_s3_bucket_name = module.apigw_openapi_bucket.s3_bucket_id # After the apigw_openapi_bucket module (in 60-s3.tf) has been created, replace 'null' with 'module.apigw_openapi_bucket.s3_bucket_id' and re-apply Terraform
  openapi_s3_object_key  = replace(var.probing_openapi_path, "./", "")

  templating_map = {
    external_authorizer_arn = aws_lambda_function.external_authorizer.invoke_arn
    cognito_authorizer_arn  = aws_lambda_function.cognito_authorizer.invoke_arn
  }

  domain_name                  = data.aws_route53_zone.probing_base.name
  disable_execute_api_endpoint = false
  enable_base_path_mapping     = false

  vpc_link_id          = aws_api_gateway_vpc_link.integration.id
  web_acl_arn          = aws_wafv2_web_acl.probing.arn # After the aws_wafv2_web_acl resource (in 10-waf.tf) has been created, replace 'null' with 'aws_wafv2_web_acl.probing.arn' and re-apply Terraform
  access_log_group_arn = aws_cloudwatch_log_group.apigw_access_logs.arn

  create_cloudwatch_alarm     = true
  create_cloudwatch_dashboard = true
  sns_topic_arn               = aws_sns_topic.platform_alarms.arn
  alarm_5xx_threshold         = 1
  alarm_5xx_period            = 60
  alarm_5xx_eval_periods      = 1
  alarm_5xx_datapoints        = 1

  create_cloudwatch_alarm_4xx    = true
  alarm_4xx_threshold_percentage = 10
  alarm_4xx_period               = 60
  alarm_4xx_eval_periods         = 1
  alarm_4xx_datapoints           = 1
}

data "aws_iam_policy_document" "apigw_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "push_logs_to_cloudwatch" {
  name               = "AWSAPIGWPushLogsToCloudWatch"
  assume_role_policy = data.aws_iam_policy_document.apigw_assume_role.json
}

resource "aws_iam_role_policy_attachment" "push_logs_to_cloudwatch" {
  role       = aws_iam_role.push_logs_to_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "current" {
  cloudwatch_role_arn = aws_iam_role.push_logs_to_cloudwatch.arn
}

resource "aws_api_gateway_usage_plan" "probing_apigw" {
  name = "${local.app_name}-usage-plan-${var.stage}"

  api_stages {
    api_id = module.probing_apigw.apigw_id
    stage  = module.probing_apigw.apigw_stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "probing_apigw" {
  key_id        = aws_api_gateway_api_key.cloudfront.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.probing_apigw.id
}

