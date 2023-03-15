output "aurora_master_credentials_secret" {
  value       = aws_secretsmanager_secret_version.aurora_master_user_credentials.version_id
  description = "Secret ID for Aurora DB master credentials"
}

output "aurora_flyway_user_credentials_secret" {
  value       = aws_secretsmanager_secret_version.aurora_interop_be_api_user_credentials.version_id
  description = "Secret ID for Aurora DB flyway user credentials"
}

output "aurora_interop_be_api_user_credentials_secret" {
  value       = aws_secretsmanager_secret_version.aurora_interop_be_api_user_credentials.version_id
  description = "Secret ID for Aurora DB  interop-be-api user credentials"
}

output "bucket_reader_role_arn" {
  value       = module.registry_reader_role.iam_role_arn
  description = "ARN of the probing bucket reader pod role"
}