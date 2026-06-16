locals {
  cross_account_image_pull = {
    "uat" = "010158505074"
  }

  repository_names = [
    "probing-be-api",
    "probing-be-caller",
    "probing-be-eservice-event-consumer",
    "probing-be-tenant-event-consumer",
    "probing-be-eservice-operations",
    "probing-be-response-updater",
    "probing-be-scheduler",
    "probing-be-statistics-api",
    "probing-be-telemetry-writer"
  ]
}

resource "aws_ecr_repository" "app" {
  for_each = toset(local.repository_names)

  image_tag_mutability = var.env == "prod" ? "IMMUTABLE" : "MUTABLE"
  name                 = each.key
}

resource "aws_ecr_lifecycle_policy" "delete_untagged" {
  for_each = var.env == "prod" ? aws_ecr_repository.app : {}

  repository = each.value.name
  policy     = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Delete untagged images",
        "selection": {
          "tagStatus": "untagged",
          "countType": "sinceImagePushed",
          "countUnit": "days",
          "countNumber": 31
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  EOF
}

resource "aws_ecr_repository_policy" "cross_account_pull" {
  for_each = var.env == "dev" ? aws_ecr_repository.app : {}

  repository = each.value.name

  policy = data.aws_iam_policy_document.cross_account_pull[0].json
}

data "aws_iam_policy_document" "cross_account_pull" {
  count = var.env == "dev" ? 1 : 0

  dynamic "statement" {
    for_each = (local.cross_account_image_pull)

    content {
      sid    = "${upper(statement.key)} Image Pull"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = ["arn:aws:iam::${statement.value}:root"]
      }

      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
      ]
    }
  }
}
