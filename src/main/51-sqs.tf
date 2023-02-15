module "sqs" {
  source  = "terraform-aws-modules/sqs/aws"

  name = "${var.app_name}-${var.env}-queue"
  fifo_queue = true

}