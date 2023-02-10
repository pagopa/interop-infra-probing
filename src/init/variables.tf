variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "env" {
  type        = string
  description = "Environment name"
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
