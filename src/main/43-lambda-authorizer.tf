resource "aws_lambda_permission" "lambda_auth_congnito_permission" {
  statement_id  = "AllowAPIGWInvokeExternalAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = "${var.app_name}-apigw-lambda-external-authorizer-${var.env}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.apigw.execution_arn}/*"
}

resource "aws_lambda_permission" "lambda_auth_external_permission" {
  statement_id  = "AllowAPIGWInvokeCognitoAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = "${var.app_name}-apigw-lambda-cognito-authorizer-${var.env}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.apigw.execution_arn}/*"
}

data "aws_iam_policy_document" "lambda_authorizer_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }

}

data "aws_iam_policy_document" "lambda_authorizer_execution_policy" {

  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup"]
    resources = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"]
  }
}

resource "aws_iam_role" "lambda_authorizer_execution_role" {
  name               = "${var.app_name}-execution-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.lambda_authorizer_assume_role_policy.json
  inline_policy {
    name   = "Logging"
    policy = data.aws_iam_policy_document.lambda_authorizer_execution_policy.json
  }
}

data "archive_file" "cognito_authorizer" {
  type        = "zip"
  source_dir  = "${path.module}/assets/cognito_authorizer"
  output_path = "cognito_authorizer.zip"
}

resource "null_resource" "external_authorizer" {
  provisioner "local-exec" {
    command = "cd ${path.module}/assets/external_authorizer/ && npm install"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

data "archive_file" "external_authorizer" {
  type        = "zip"
  source_dir  = "${path.module}/assets/external_authorizer"
  output_path = "external_authorizer.zip"
  depends_on  = [null_resource.external_authorizer]
}

data "local_file" "role_mapping" {
  filename = "${path.module}/assets/cognito_authorizer/cognito_role_mapping-${var.env}.json"
}


resource "aws_lambda_function" "cognito_authorizer" {
  filename         = "cognito_authorizer.zip"
  function_name    = "${var.app_name}-apigw-lambda-cognito-authorizer-${var.env}"
  role             = aws_iam_role.lambda_authorizer_execution_role.arn
  handler          = "lambda_authorizer.handler"
  source_code_hash = data.archive_file.cognito_authorizer.output_base64sha256
  runtime          = "nodejs16.x"
  environment {
    variables = {
      ENV          = var.env
      ROLE_MAPPING = data.local_file.role_mapping.content
    }
  }
}

resource "aws_lambda_function" "external_authorizer" {
  filename         = "external_authorizer.zip"
  function_name    = "${var.app_name}-apigw-lambda-external-authorizer-${var.env}"
  role             = aws_iam_role.lambda_authorizer_execution_role.arn
  handler          = "lambda_authorizer.handler"
  source_code_hash = data.archive_file.external_authorizer.output_base64sha256
  runtime          = "nodejs16.x"
  environment {
    variables = {
      ENV = var.env
    JWKS_URI = var.jwks_uri }
  }
}