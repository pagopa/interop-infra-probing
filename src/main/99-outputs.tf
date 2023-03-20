output "bucket_reader_role_arn" {
  value       = module.registry_reader_role.iam_role_arn
  description = "ARN of the probing bucket reader pod role"
}