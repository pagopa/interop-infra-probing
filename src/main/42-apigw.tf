resource "aws_api_gateway_rest_api" "apigw" {
  name        = "${var.app_name}-apigw-${var.env}"
  description = "${var.app_name} API Gateway"
}


resource "aws_api_gateway_vpc_link" "main" {
  name        = "${var.app_name}-vpclink-${var.env}"
  target_arns = [aws_lb.nlb.arn]
}