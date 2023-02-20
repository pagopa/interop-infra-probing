module "sqs" {
  source = "terraform-aws-modules/sqs/aws"
  version = "4.0.1"
  name       = "${var.app_name}-bucket_reader_queue-${var.env}"
  fifo_queue = true
}
