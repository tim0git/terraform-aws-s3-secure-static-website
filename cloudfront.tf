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

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

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
    min_ttl                    = 0
    default_ttl                = 86400
    max_ttl                    = 31536000
    compress                   = var.compress
  }
  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    target_origin_id = "s3-cloudfront-origin-control"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

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
    min_ttl                    = var.default_root_object_cache_behaviour.min_ttl
    default_ttl                = var.default_root_object_cache_behaviour.default_ttl
    max_ttl                    = var.default_root_object_cache_behaviour.max_ttl
    compress                   = var.compress
    path_pattern               = "/${var.default_root_object}"
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

  custom_error_response {
    error_code            = 403
    response_code         = 200
    error_caching_min_ttl = 0
    response_page_path    = "/"
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
