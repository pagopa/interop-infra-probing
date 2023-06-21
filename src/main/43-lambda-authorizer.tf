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

data "archive_file" "cognito_authorizer" {
  type        = "zip"
  source_dir  = "${path.module}/assets/cognito_authorizer"
  output_path = "cognito_authorizer.zip"
}

data "archive_file" "external_authorizer" {
  type        = "zip"
  source_dir  = "${path.module}/assets/external_authorizer"
  output_path = "external_authorizer.zip"
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
      #JWKS_URI = var.jwks_uri
      JWKS_URI = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.user_pool.id}/.well-known/jwks.json"
    }
  }
}