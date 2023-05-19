locals {
  openapi_spec = var.openapi_spec_path
}

resource "aws_api_gateway_rest_api" "apigw" {
  name        = "${var.app_name}-apigw-${var.env}"
  description = "${var.app_name} API Gateway"
  body        = file(local.openapi_spec)
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.apigw.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id        = aws_api_gateway_deployment.deployment.id
  rest_api_id          = aws_api_gateway_rest_api.apigw.id
  stage_name           = var.env
  xray_tracing_enabled = true
  variables = {
    aws_lb_nlb_dns_name                 = trimspace(aws_lb.nlb.dns_name)
    aws_api_gateway_vpc_link_backend_id = trimspace(aws_api_gateway_vpc_link.backend.id)
  }
}

resource "aws_api_gateway_method_settings" "settings" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

resource "aws_api_gateway_vpc_link" "backend" {
  name        = "${var.app_name}-vpclink-${var.env}"
  target_arns = [aws_lb.nlb.arn]
}

data "aws_iam_policy_document" "apigw_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cloudwatch" {
  name               = "api_gateway_cloudwatch_global"
  assume_role_policy = data.aws_iam_policy_document.apigw_assume_role.json
}

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]

    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "cloudwatch" {
  name   = "${var.app_name}-cloudwatch-${var.env}"
  role   = aws_iam_role.cloudwatch.id
  policy = data.aws_iam_policy_document.cloudwatch.json
}

resource "aws_api_gateway_account" "apigw_account" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_api_gateway_usage_plan" "main" {
  name = "${var.app_name}-usage-plan-${var.env}"

  api_stages {
    api_id = aws_api_gateway_rest_api.apigw.id
    stage  = aws_api_gateway_stage.stage.stage_name
  }

}


resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.cloudfront.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.main.id
}

