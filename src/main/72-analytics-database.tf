resource "aws_timestreamwrite_database" "analytics_database" {
  database_name = var.analytics_database_name
}

resource "aws_timestreamwrite_table" "probing_telemetry" {
  database_name = aws_timestreamwrite_database.analytics_database.database_name
  table_name    = "probing_telemetry"
  retention_properties {
    magnetic_store_retention_period_in_days = var.timestream_table_magnetic_store_retention_period_in_days
    memory_store_retention_period_in_hours  = var.timestream_table_memory_store_retention_period_in_hours
  }
}