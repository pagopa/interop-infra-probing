module "sqs" {
  source = "terraform-aws-modules/sqs/aws"

  name       = "${var.app_name}-bucket_reader_queue-${var.env}"
  fifo_queue = true

}
