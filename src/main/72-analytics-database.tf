resource "aws_timestreamwrite_database" "analytics_database" {
  database_name = var.analytics_database_name
}

resource "aws_timestreamwrite_table" "probing_telemetry" {
  database_name = aws_timestreamwrite_database.analytics_database.database_name
  table_name    = "probing_telemetry"
}