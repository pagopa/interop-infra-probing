# locals {
#   repository_names = [
#     "tracing-be-api",
#   ]
# }

# resource "aws_ecr_repository" "app" {
#   for_each = toset(local.repository_names)

#   image_tag_mutability = "MUTABLE" # needed to override "latest" tag
#   name                 = each.key
# }

# resource "aws_ecr_lifecycle_policy" "delete_untagged" {
#   for_each = aws_ecr_repository.app

#   repository = each.value.name
#   policy     = <<EOF
#   {
#     "rules": [
#       {
#         "rulePriority": 1,
#         "description": "Delete untagged images",
#         "selection": {
#           "tagStatus": "untagged",
#           "countType": "sinceImagePushed",
#           "countUnit": "days",
#           "countNumber": 31
#         },
#         "action": {
#           "type": "expire"
#         }
#       }
#     ]
#   }
#   EOF
# }

# resource "aws_ecr_repository_policy" "cross_account_pull" {
#   for_each = var.env == "prod" ? aws_ecr_repository.app : {}

#   repository = each.value.name

#   policy = jsonencode({
#     Version = "2008-10-17",
#     Statement = [
#       {
#         Sid    = "DEV Image Pull",
#         Effect = "Allow",
#         Principal = {
#           AWS = "arn:aws:iam::774300547186:root"
#         },
#         Action = [
#           "ecr:BatchCheckLayerAvailability",
#           "ecr:BatchGetImage",
#           "ecr:GetDownloadUrlForLayer"
#         ]
#       },
#       {
#         Sid    = "UAT Image Pull",
#         Effect = "Allow",
#         Principal = {
#           AWS = "arn:aws:iam::010158505074:root"
#         },
#         Action = [
#           "ecr:BatchCheckLayerAvailability",
#           "ecr:BatchGetImage",
#           "ecr:GetDownloadUrlForLayer"
#         ]
#       }
#     ]
#   })
# }
