resource "aws_api_gateway_api_key" "cloudfront" {
  name = "${var.app_name}-cloudfront-${var.env}"
}

module "fe_cdn" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.2.1"

  comment             = "${var.app_name} CDN"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  origin = {
    fe_hosting_oac = {
      domain_name           = module.fe_s3_bucket.s3_bucket_bucket_domain_name
      origin_access_control = "fe_hosting_oac"
    }

    apigw = {
      origin_id   = var.api_gateway_origin_id
      domain_name = "${aws_api_gateway_rest_api.apigw.id}.execute-api.${var.aws_region}.amazonaws.com"
      origin_path = "/${aws_api_gateway_stage.stage.stage_name}"

      custom_header = [{
        name  = "x-api-key"
        value = aws_api_gateway_api_key.cloudfront.value
      }]

      custom_origin_config = {
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
        http_port              = 80
        https_port             = 443
      }
    }
  }

  create_origin_access_control = true
  origin_access_control = {
    fe_hosting_oac = {
      description      = "CloudFront access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  default_cache_behavior = {
    target_origin_id       = "fe_hosting_oac"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }
}
