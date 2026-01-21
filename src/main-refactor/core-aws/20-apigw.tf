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