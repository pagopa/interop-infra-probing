resource "aws_sns_topic" "cw_alarms" {
  name = "${var.app_name}-cwalarms-${var.env}"
}