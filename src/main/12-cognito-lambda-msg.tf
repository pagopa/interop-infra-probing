resource "aws_lambda_permission" "allow_cognito" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cognito_messaging.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.user_pool.arn
}

data "aws_iam_policy_document" "congito_messaging_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_cognito_messaging_execution_role" {
  name               = "${var.app_name}-cognito-messaging-invocation-policy-${var.env}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.congito_messaging_assume_role.json
}

resource "null_resource" "lambda_cognito_messaging" {
  provisioner "local-exec" {
    command = "cd ${path.module}/assets/lambda_cognito_messaging/ && npm install && zip -qr lambda_cognito_messaging.zip ."
  }

  triggers = {
    index   = sha256(file("${path.module}/assets/lambda_cognito_messaging/index.js"))
    package = sha256(file("${path.module}/assets/lambda_cognito_messaging/package.json"))
    lock    = sha256(file("${path.module}/assets/lambda_cognito_messaging/package-lock.json"))
  }
}

resource "aws_s3_object" "lambda_cognito_messaging" {
  count      = fileexists("${path.module}/assets/lambda_cognito_messaging/lambda_cognito_messaging.zip") ? 0 : 1
  bucket     = module.lambda_packages_bucket.s3_bucket_id
  key        = "lambda_cognito_messaging.zip"
  source     = "${path.module}/assets/lambda_cognito_messaging/lambda_cognito_messaging.zip"
  depends_on = [null_resource.lambda_cognito_messaging]
}


resource "aws_lambda_function" "cognito_messaging" {
  s3_bucket     = module.lambda_packages_bucket.s3_bucket_id
  s3_key        = aws_s3_object.cognito_messaging.id
  function_name = "${var.app_name}-lambda-cognito-messaging-${var.env}"
  role          = aws_iam_role.lambda_cognito_messaging_execution_role.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  environment {
    variables = {
      ENV                   = var.env
      FE_URL                = var.fe_base_url
      RESET_PASSOWORD_ROUTE = "/ripristino-password"
      LOGIN_ROUTE           = "/login"
    }
  }
}