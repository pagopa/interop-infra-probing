resource "aws_api_gateway_api_key" "cloudfront" {
  name = "${var.app_name}-cloudfront-${var.env}"
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
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
      origin_id   = "apigw"
      domain_name = replace(aws_api_gateway_stage.stage.invoke_url, "/http[s]?:///", "")

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
    cache_policy_id = data.aws_cloudfront_cache_policy.caching_optimized.id
  }
  ordered_cache_behavior = [
    {
      path_pattern             = "/eservices/*"
      target_origin_id         = "apigw"
      viewer_protocol_policy   = "redirect-to-https"
      cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
      allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      compress                 = true
    },
    {
      path_pattern             = "/producers/*"
      target_origin_id         = "apigw"
      viewer_protocol_policy   = "redirect-to-https"
      cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
      allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      compress                 = true
    }
  ]
}
