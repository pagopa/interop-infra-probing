module "sqs_registry_queue" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.0.1"

  name                        = "eservice_registry_queue"
  fifo_queue                  = true
  content_based_deduplication = true
}

module "sqs_polling_queue" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.0.1"

  name = "eservice_polling_queue"

}


module "sqs_polling_result_queue" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.0.1"

  name = "eservice_polling_result_queue"

}


module "sqs_telemetry_result_queue" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.0.1"

  name = "eservice_telemetry_result_queue"

}
