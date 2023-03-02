output "aurora_master_password_secret" {
  value       = aws_secretsmanager_secret_version.database_aurora_master_password.version_id
  description = "Secret ID for Aurora DB master password"
}

output "bucket_reader_role_arn" {
  value       = module.registry_reader_role.iam_role_arn
  description = "Role arn of the probing bucket reader podRole"
}