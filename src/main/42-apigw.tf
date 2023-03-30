locals {
  openapi_spec = "${path.module}/assets/openapi_spec/${var.app_name}-${var.env}-api-${var.api_version}.yaml"
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
    aws_lb_nlb_dns_name                 = aws_lb.nlb.dns_name
    aws_api_gateway_vpc_link_backend_id = aws_api_gateway_vpc_link.backend.id
  }
}

resource "aws_api_gateway_method_settings" "settings" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    logging_level      = "NONE"
    data_trace_enabled = true
  }
}

resource "aws_api_gateway_vpc_link" "backend" {
  name        = "${var.app_name}-vpclink-${var.env}"
  target_arns = [aws_lb.nlb.arn]
}