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
  default = {
    "CreatedBy" : "Terraform",
  }
}
