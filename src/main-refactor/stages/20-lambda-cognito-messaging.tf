resource "aws_lambda_permission" "allow_cognito_invoke_lambda_messaging" {
  statement_id  = "AllowCognitoInvokeLambdaMessaging"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cognito_messaging.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.user_pool.arn
}

data "aws_iam_policy_document" "lambda_assume_role" {
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
  name               = "${local.app_name}-cognito-messaging-execution-role-${var.stage}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "null_resource" "lambda_cognito_messaging" {
  provisioner "local-exec" {
    command = "cd ${path.module}/lambda/lambda_cognito_messaging/ && npm install"
  }

  triggers = {
    source_hash = sha256(
      join("", [
        filesha256("${path.module}/lambda/lambda_cognito_messaging/package.json"),
        filesha256("${path.module}/lambda/lambda_cognito_messaging/package-lock.json"),
        filesha256("${path.module}/lambda/lambda_cognito_messaging/lambda_cognito_messaging.js")
      ])
    )
  }
}

data "archive_file" "lambda_cognito_messaging" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/lambda_cognito_messaging"
  output_path = "${path.module}/lambda/lambda_cognito_messaging/lambda_cognito_messaging.zip"
  depends_on  = [null_resource.lambda_cognito_messaging]
}

resource "aws_lambda_function" "cognito_messaging" {
  filename         = data.archive_file.lambda_cognito_messaging.output_path
  function_name    = "${local.app_name}-lambda-cognito-messaging-${var.stage}"
  role             = aws_iam_role.lambda_cognito_messaging_execution_role.arn
  handler          = "lambda_cognito_messaging.handler"
  source_code_hash = data.archive_file.lambda_cognito_messaging.output_base64sha256
  runtime          = "nodejs16.x"

  environment {
    variables = {
      ENV                   = var.stage
      FE_URL                = var.fe_base_url
      RESET_PASSOWORD_ROUTE = "/ripristino-password"
      LOGIN_ROUTE           = "/login"
    }
  }
}