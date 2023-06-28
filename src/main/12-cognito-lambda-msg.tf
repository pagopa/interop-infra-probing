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
    command = "cd ${path.module}/assets/lambda_cognito_messaging/ && npm install"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

data "archive_file" "lambda_cognito_messaging" {
  type        = "zip"
  source_dir  = "${path.module}/assets/lambda_cognito_messaging"
  output_path = "lambda_cognito_messaging.zip"
}

resource "aws_lambda_function" "cognito_messaging" {
  filename         = "lambda_cognito_messaging.zip"
  function_name    = "${var.app_name}-lambda-cognito-messaging-${var.env}"
  role             = aws_iam_role.lambda_cognito_messaging_execution_role.arn
  handler          = "lambda_cognito_messaging.handler"
  source_code_hash = data.archive_file.lambda_cognito_messaging.output_base64sha256
  runtime          = "nodejs16.x"
  environment {
    variables = {
      ENV                   = var.env
      FE_URL                = var.fe_base_url
      RESET_PASSOWORD_ROUTE = "/ripristino-password"
      LOGIN_ROUTE           = "/login"
    }
  }
}