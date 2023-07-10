resource "aws_sns_topic" "cw_alarms" {
  name = "${var.app_name}-cwalarms-${var.env}"
}

data "aws_iam_policy_document" "cw_alarms_publish" {
  policy_id = "${var.app_name}-cwalarms-publish-${var.env}"

  statement {
    actions = [
      "SNS:Publish"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.cw_alarms.arn,
    ]

    sid = "PublishOnSNS"
  }
}

resource "aws_sns_topic_policy" "cw_alarms_publish" {
  arn = aws_sns_topic.cw_alarms.arn

  policy = data.aws_iam_policy_document.cw_alarms_publish.json
}

resource "aws_sns_topic" "ses_events" {
  name = "${var.app_name}-ses-events-${var.env}"
}

resource "aws_sns_topic_policy" "ses_publish" {
  arn = aws_sns_topic.ses_events.arn

  policy = jsonencode({
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ses.amazonaws.com"
        },
        Action   = "sns:Publish",
        Resource = aws_sns_topic.ses_events.arn
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" : data.aws_caller_identity.current.account_id,
            "AWS:SourceArn" : aws_sesv2_email_identity.stato_eservice.arn
          }
        }
      }
    ]
  })
}
