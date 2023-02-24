module "sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.0.1"

  name       = "eservice_registry_queue"
  fifo_queue = true
}

module "sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.0.1"

  name = "eservice_polling_queue"

}


module "sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.0.1"

  name = "eservice_polling_result_queue"

}


module "sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.0.1"

  name = "eservice_telemetry_result_queue"

}
