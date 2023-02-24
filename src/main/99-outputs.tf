output "aurora_master_password_secret" {
  value       = aws_secretsmanager_secret_version.database_aurora_master_password.version_id
  description = "Secret ID for Aurora DB master password"
}