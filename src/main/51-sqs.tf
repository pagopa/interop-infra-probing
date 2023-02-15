module "sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "~> 4.0.1"

  name = "${var.app_name}-${var.env}-queue"
  fifo_queue = true

}