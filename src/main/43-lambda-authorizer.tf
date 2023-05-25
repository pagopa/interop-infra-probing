resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name                   = "lambda-authorizer-${var.env}"
  rest_api_id            = aws_api_gateway_rest_api.apigw.id
  authorizer_uri         = aws_lambda_function.authorizer.invoke_arn
  authorizer_credentials = aws_iam_role.invocation_role.arn
}

data "aws_iam_policy_document" "invocation_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "invocation_role" {
  name               = "${var.app_name}-apigw-auth-invocation-${var.env}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.invocation_assume_role.json
}

data "aws_iam_policy_document" "invocation_policy" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.authorizer.arn]
  }
}

resource "aws_iam_role_policy" "invocation_policy" {
  name   = "${var.app_name}-invocation-policy-${var.env}"
  role   = aws_iam_role.invocation_role.id
  policy = data.aws_iam_policy_document.invocation_policy.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_authorizer_execution_role" {
  name               = "${var.app_name}-invocation-policy-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/assets/lambda_authorizer"
  output_path = "lambda_authorizer.zip"
}

resource "aws_lambda_function" "authorizer" {
  filename         = "lambda_authorizer.zip"
  function_name    = "${var.app_name}-apigw-lambda-authorizer-${var.env}"
  role             = aws_iam_role.lambda_authorizer_execution_role.arn
  handler          = "lambda_authorizer.handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "nodejs16.x"
}