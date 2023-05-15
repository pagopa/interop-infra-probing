output "bucket_reader_role_arn" {
  value       = module.registry_reader_role.iam_role_arn
  description = "ARN of the probing bucket reader pod role"
}

output "cloudfront_distribution_domain_name" {
  value       = module.fe_cdn.cloudfront_distribution_domain_name
  description = "Domain name for the cloudfront distribution"
}

output "frontend_deploy_role_arn" {
  value       = aws_iam_role.frontend_github_pipeline.arn
  description = "ARN of the role for frontend github pipeline"
}

output "probing_public_hosted_zone_ns" {
  value       = aws_route53_zone.probing_public.name_servers
  description = "NS values for the probing public hosted zone in this environment"
}
