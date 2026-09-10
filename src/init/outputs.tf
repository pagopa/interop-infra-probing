output "backend_bucket_name" {
  value       = aws_s3_bucket.terraform_states.bucket
  description = "Name of the S3 bucket used for storing Terraform state files."
}

output "iac_role_arn" {
  value       = aws_iam_role.githubiac.arn
  description = "Role to use in github actions to build the infrastructure."
}