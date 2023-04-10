#tfsec:ignore:aws-cloudfront-enable-logging - logging is dynamic and triggered by input variables.
resource "aws_cloudfront_distribution" "this" {
  aliases = local.domain_names

  depends_on = [
    aws_s3_bucket.this
  ]

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object
  price_class         = var.price_class
  web_acl_id          = var.aws_waf_arn
  wait_for_deployment = false

  origin {
    domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
    origin_id                = "s3-cloudfront-origin-control"
  }

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    target_origin_id = "s3-cloudfront-origin-control"

    dynamic "lambda_function_association" {
      for_each = var.lambda_function_associations
      content {
        event_type   = lambda_function_association.value.event_type
        lambda_arn   = lambda_function_association.value.lambda_arn
        include_body = lambda_function_association.value.include_body
      }
    }

    response_headers_policy_id = var.aws_cloudfront_response_headers_policy_id
    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id            = data.aws_cloudfront_cache_policy.managed_caching_optimized.id
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.managed_s3_origin_cors.id
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behavior
    content {
      allowed_methods = [
        "GET",
        "HEAD",
      ]

      cached_methods = [
        "GET",
        "HEAD",
      ]

      target_origin_id = "s3-cloudfront-origin-control"

      dynamic "lambda_function_association" {
        for_each = var.lambda_function_associations
        content {
          event_type   = lambda_function_association.value.event_type
          lambda_arn   = lambda_function_association.value.lambda_arn
          include_body = lambda_function_association.value.include_body
        }
      }

      response_headers_policy_id = var.aws_cloudfront_response_headers_policy_id
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = ordered_cache_behavior.value.cache_enabled ? data.aws_cloudfront_cache_policy.managed_caching_optimized.id : data.aws_cloudfront_cache_policy.managed_caching_disabled.id
      origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.managed_s3_origin_cors.id
      path_pattern               = ordered_cache_behavior.value.path_pattern
    }
  }

  dynamic "logging_config" {
    for_each = local.cloudfront_logging_enabled
    content {
      include_cookies = var.include_cookies
      bucket          = var.cloudfront_logs_bucket
      prefix          = replace(join(", ", reverse(split(".", var.domain_name))), ", ", "/")
    }
  }

  dynamic "restrictions" {
    for_each = local.geo_restrictions_enabled
    content {
      geo_restriction {
        restriction_type = var.geo_restrictions[0].restriction_type
        locations        = var.geo_restrictions[0].locations
      }
    }
  }
  dynamic "restrictions" {
    for_each = local.geo_restrictions_disabled
    content {
      geo_restriction {
        restriction_type = "none"
        locations        = []
      }
    }
  }

  dynamic "viewer_certificate" {
    for_each = local.default_certs
    content {
      cloudfront_default_certificate = true
    }
  }
  dynamic "viewer_certificate" {
    for_each = local.acm_certs
    content {
      acm_certificate_arn      = data.aws_acm_certificate.acm_cert[0].arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1.2_2021"
    }
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code            = custom_error_response.key
      response_code         = custom_error_response.value.response_code
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
      response_page_path    = custom_error_response.value.response_page_path
    }
  }

  tags = var.tags
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "SAC-${var.domain_name}"
  description                       = "Secure origin access control for ${var.domain_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
