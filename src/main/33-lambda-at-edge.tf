data "archive_file" "well_known" {
  type        = "zip"
  source_dir  = "${path.module}/assets/well_known"
  output_path = "well_known.zip"
}

data "aws_iam_policy" "lambda_at_edge_execution_policy" {

  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "lambda_at_edge_execution_role" {
  name               = "${var.app_name}-edge-execution-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.lambda_at_edge_assume_role_policy.json
  inline_policy {
    name   = "Logging"
    policy = data.aws_iam_policy.lambda_at_edge_execution_policy.policy
  }
}

data "aws_iam_policy_document" "lambda_at_edge_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }

}

resource "aws_lambda_function" "well_known" {
  provider         = aws.us_east_1
  filename         = "well_known.zip"
  function_name    = "${var.app_name}-well-known-edge-${var.env}"
  role             = aws_iam_role.lambda_at_edge_execution_role.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.well_known.output_base64sha256
  runtime          = "nodejs16.x"
  timeout          = 15
  publish          = true
  environment {
    variables = {
      ENV = var.env
      #S3_BUCKET = module.well_known_s3_bucket.s3_bucket_id
      KID = aws_kms_key.jwt_sign_key.key_id
    }
  }
}