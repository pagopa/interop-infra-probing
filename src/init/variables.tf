variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "github_repository" {
  type        = string
  description = "Github repository for this configuration"
}

variable "tags" {
  type = map(any)
  description = "Tags to apply to AWS resources created by Terraform"
  default = {
    "CreatedBy" : "Terraform",
  }
}
