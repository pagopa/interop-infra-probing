data "aws_secretsmanager_secret" "timestream_influxdb_admin" {
  name = var.timestream_influxdb_admin_credentials_secret_name
}