# resource "aws_timestreamwrite_table" "probing_telemetry" {
#   database_name = data.aws_timestreamwrite_database.probing_analytics_database.database_name
#   table_name    = format("probing_telemetry_%s", var.stage)

#   retention_properties {
#     magnetic_store_retention_period_in_days = var.timestream_table_magnetic_store_retention_period_in_days
#     memory_store_retention_period_in_hours  = var.timestream_table_memory_store_retention_period_in_hours
#   }
# }