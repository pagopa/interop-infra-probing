output "bucket_reader_role_arn" {
  value       = module.registry_reader_role.iam_role_arn
  description = "ARN of the probing bucket reader pod role"
}

output "cloudfront_distribution_domain_name" {
  value       = module.fe_cdn.cloudfront_distribution_domain_name
  description = "Domain name for the cloudfront distribution"
}

output "cloudfront_distribution_domain_name" {
  value       = aws_iam_role.frontend_github_pipeline_role.arn
  description = "ARN of the role for github action"
}