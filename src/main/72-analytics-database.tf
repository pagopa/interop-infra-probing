resource "aws_timestreamwrite_database" "analytics_database" {
  database_name = var.analytics_database_name
}