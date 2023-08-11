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
    command = "cd ${path.module}/assets/cognito_authorizer/ && npm install && zip -qr cognito_authorizer.zip ."
  }

  triggers = {
    index        = sha256(file("${path.module}/assets/cognito_authorizer/index.js"))
    package      = sha256(file("${path.module}/assets/cognito_authorizer/package.json"))
    lock         = sha256(file("${path.module}/assets/cognito_authorizer/package-lock.json"))
    role_mapping = sha256(file("${path.module}/assets/cognito_authorizer/cognito_role_mapping-${var.env}.json"))
  }
}

resource "aws_s3_object" "cognito_authorizer" {
  count      = fileexists("${path.module}/assets/cognito_authorizer/cognito_authorizer.zip") ? 0 : 1
  bucket     = module.lambda_packages_bucket.s3_bucket_id
  key        = "cognito_authorizer.zip"
  source     = "${path.module}/assets/cognito_authorizer/cognito_authorizer.zip"
  depends_on = [null_resource.cognito_authorizer]
}


resource "aws_lambda_function" "cognito_authorizer" {
  depends_on = [ aws_s3_object.cognito_authorizer ]
  s3_bucket     = module.lambda_packages_bucket.s3_bucket_id
  s3_key        = "cognito_authorizer.zip"
  function_name = "${var.app_name}-apigw-lambda-cognito-authorizer-${var.env}"
  role          = aws_iam_role.lambda_authorizer_execution_role.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  timeout       = 15
  environment {
    variables = {
      ENV                = var.env
      JWKS_URI           = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.user_pool.id}/.well-known/jwks.json"
      JWKS_CACHE_ENABLED = var.lambda_authorizer_cache_enabled
      JWKS_CACHE_MAX_AGE = var.lambda_authorizer_cache_max_age
    }
  }
}

resource "null_resource" "external_authorizer" {
  provisioner "local-exec" {
    command = "cd ${path.module}/assets/external_authorizer/ && npm install && zip -qr external_authorizer.zip ."
  }

  triggers = {
    index   = sha256(file("${path.module}/assets/external_authorizer/index.js"))
    package = sha256(file("${path.module}/assets/external_authorizer/package.json"))
    lock    = sha256(file("${path.module}/assets/external_authorizer/package-lock.json"))
  }
}


resource "aws_s3_object" "external_authorizer" {
  count      = fileexists("${path.module}/assets/external_authorizer/external_authorizer.zip") ? 0 : 1
  bucket     = module.lambda_packages_bucket.s3_bucket_id
  key        = "external_authorizer.zip"
  source     = "${path.module}/assets/external_authorizer/external_authorizer.zip"
  depends_on = [null_resource.external_authorizer]
}




resource "aws_lambda_function" "external_authorizer" {
  depends_on = [ aws_s3_object.external_authorizer ]
  s3_bucket     = module.lambda_packages_bucket.s3_bucket_id
  s3_key        = "external_authorizer.zip"
  function_name = "${var.app_name}-apigw-lambda-external-authorizer-${var.env}"
  role          = aws_iam_role.lambda_authorizer_execution_role.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  timeout       = 15
  environment {
    variables = {
      ENV                = var.env
      JWKS_URI           = var.jwks_uri
      JWKS_CACHE_ENABLED = var.lambda_authorizer_cache_enabled
      JWKS_CACHE_MAX_AGE = var.lambda_authorizer_cache_max_age
    }
  }
}