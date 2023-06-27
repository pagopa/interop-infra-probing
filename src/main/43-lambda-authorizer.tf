resource "aws_lambda_permission" "lambda_auth_external_permission" {
  statement_id  = "AllowAPIGWInvokeExternalAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.external_authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.apigw.execution_arn}/*"
}

resource "aws_lambda_permission" "lambda_auth_cognito_permission" {
  statement_id  = "AllowAPIGWInvokeCognitoAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cognito_authorizer.function_name
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

data "aws_iam_policy" "lambda_authorizer_execution_policy" {

  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "lambda_authorizer_execution_role" {
  name               = "${var.app_name}-execution-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.lambda_authorizer_assume_role_policy.json
  inline_policy {
    name   = "Logging"
    policy = data.aws_iam_policy.lambda_authorizer_execution_policy.policy
  }
}

resource "null_resource" "cognito_authorizer" {
  provisioner "local-exec" {
    command = "cd ${path.module}/assets/cognito_authorizer/ && npm install"
  }

  triggers = {
    index   = sha256(file("${path.module}/assets/cognito_authorizer/lambda_authorizer.js"))
    mapping = sha256(file("${path.module}/assets/cognito_authorizer/cognito_role_mapping-dev.json"))
    lock    = sha256(file("${path.module}/assets/cognito_authorizer/package-lock.json"))
    package = sha256(file("${path.module}/assets/cognito_authorizer/package.json"))
  }
}

data "archive_file" "cognito_authorizer" {
  type        = "zip"
  source_dir  = "${path.module}/assets/cognito_authorizer"
  output_path = "cognito_authorizer.zip"
  depends_on  = [null_resource.cognito_authorizer]
}

resource "null_resource" "external_authorizer" {
  provisioner "local-exec" {
    command = "cd ${path.module}/assets/external_authorizer/ && npm install"
  }

  triggers = {
    index   = sha256(file("${path.module}/assets/external_authorizer/lambda_authorizer.js"))
    lock    = sha256(file("${path.module}/assets/external_authorizer/package-lock.json"))
    package = sha256(file("${path.module}/assets/external_authorizer/package.json"))
  }
}

data "archive_file" "external_authorizer" {
  type        = "zip"
  source_dir  = "${path.module}/assets/external_authorizer"
  output_path = "external_authorizer.zip"
  depends_on  = [null_resource.external_authorizer]
}



resource "aws_lambda_function" "cognito_authorizer" {
  filename         = "cognito_authorizer.zip"
  function_name    = "${var.app_name}-apigw-lambda-cognito-authorizer-${var.env}"
  role             = aws_iam_role.lambda_authorizer_execution_role.arn
  handler          = "lambda_authorizer.handler"
  source_code_hash = data.archive_file.cognito_authorizer.output_base64sha256
  runtime          = "nodejs16.x"
  timeout          = 15
  environment {
    variables = {
      ENV                = var.env
      JWKS_URI           = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.user_pool.id}/.well-known/jwks.json"
      JWKS_CACHE_ENABLED = var.lambda_authorizer_cache_enabled
      JWKS_CACHE_MAX_AGE = var.lambda_authorizer_cache_max_age
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
  timeout          = 15
  environment {
    variables = {
      ENV                = var.env
      JWKS_URI           = var.jwks_uri
      JWKS_CACHE_ENABLED = var.lambda_authorizer_cache_enabled
      JWKS_CACHE_MAX_AGE = var.lambda_authorizer_cache_max_age
    }
  }
}