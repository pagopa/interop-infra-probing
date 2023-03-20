output "bucket_reader_role_arn" {
  value       = module.registry_reader_role.iam_role_arn
  description = "ARN of the probing bucket reader pod role"
}

output "cloudfront_distribution_domain_name" {
  value       = module.fe_cdn.cloudfront_distribution_domain_name
  description = "Domain name for the cloudfront distribution"
}
