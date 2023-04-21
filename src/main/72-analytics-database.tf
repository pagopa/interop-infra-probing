resource "aws_timestreamwrite_database" "analytics_database" {
  database_name = var.analytics_database_name
}

resource "aws_timestreamwrite_table" "polling_measurements" {
  database_name = aws_timestreamwrite_database.analytics_database.database_name
  table_name    = "polling_measurements"
}