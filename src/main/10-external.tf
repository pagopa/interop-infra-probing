data "aws_s3_bucket" "interop_probing_bucket" {
  bucket = var.interop_probing_bucket_name
}