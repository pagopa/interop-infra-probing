resource "aws_xray_sampling_rule" "health_check" {
  rule_name      = "${var.app_name}-healthcheck-${var.env}"
  priority       = 1
  version        = 1
  reservoir_size = 0
  fixed_rate     = 0
  url_path       = "/status"
  host           = "*"
  http_method    = "*"
  service_type   = "*"
  service_name   = "*"
  resource_arn   = "*"
}

# resource "aws_xray_sampling_rule" "external" {
#   rule_name      = "${var.app_name}-external-${var.env}"
#   priority       = 9999
#   version        = 1
#   reservoir_size = 100
#   fixed_rate     = 0.05
#   url_path       = "*"
#   host           = "*"
#   http_method    = "*"
#   service_type   = "*"
#   service_name   = "*"
#   resource_arn   = "*"
# }

# resource "aws_xray_sampling_rule" "internal" {
#   rule_name      = "${var.app_name}-internal-${var.env}"
#   priority       = 9999
#   version        = 1
#   reservoir_size = 100
#   fixed_rate     = 0.01
#   url_path       = "*"
#   host           = "*"
#   http_method    = "*"
#   service_type   = "*"
#   service_name   = "*"
#   resource_arn   = "*"
# }