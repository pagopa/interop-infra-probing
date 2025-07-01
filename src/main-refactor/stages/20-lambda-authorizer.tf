data "aws_api_gateway_rest_api" "probing_apigw" {
  depends_on = [module.probing_apigw]

  name = module.probing_apigw.apigw_name
}

resource "aws_lambda_permission" "allow_apigw_invoke_external_authorizer" {
  statement_id  = "AllowAPIGWInvokeLambdaExternalAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.external_authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${data.aws_api_gateway_rest_api.probing_apigw.execution_arn}/*"
}

resource "aws_lambda_permission" "allow_apigw_invoke_cognito_authorizer" {
  statement_id  = "AllowAPIGWInvokeLambdaCognitoAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cognito_authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${data.aws_api_gateway_rest_api.probing_apigw.execution_arn}/*"
}

data "aws_iam_policy" "lambda_authorizer_execution_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "lambda_authorizer_execution_role" {
  name               = "${local.app_name}-execution-role-${var.stage}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

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
    always_run = "${timestamp()}"
  }
}

data "archive_file" "cognito_authorizer" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/cognito_authorizer"
  output_path = "${path.module}/lambda/cognito_authorizer/cognito_authorizer.zip"
  depends_on  = [null_resource.cognito_authorizer]
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
  source_dir  = "${path.module}/lambda/external_authorizer"
  output_path = "${path.module}/lambda/external_authorizer/external_authorizer.zip"
  depends_on  = [null_resource.external_authorizer]
}

resource "aws_lambda_function" "cognito_authorizer" {
  filename         = data.archive_file.cognito_authorizer.output_path
  function_name    = "${local.app_name}-apigw-lambda-cognito-authorizer-${var.stage}"
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
  filename         = data.archive_file.external_authorizer.output_path
  function_name    = "${local.app_name}-apigw-lambda-external-authorizer-${var.stage}"
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