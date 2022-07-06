locals {
  logging_enabled           = var.s3_log_bucket != "" ? [{}] : []
  geo_restrictions_enabled  = var.geo_restrictions != [] ? [{}] : []
  geo_restrictions_disabled = var.geo_restrictions != [] ? [] : [{}]
  default_certs             = var.use_default_domain ? ["default"] : []
  acm_certs                 = var.use_default_domain ? [] : ["acm"]
  domain_names              = concat([var.domain_name], var.aliases)
}

provider "aws" {
  region = "us-east-1"
  alias  = "aws_cloudfront"
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.domain_name
  tags   = var.tags
}

resource "aws_s3_bucket_acl" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

resource "aws_s3_object" "s3_bucket" {
  count        = var.upload_sample_file ? 1 : 0
  bucket       = aws_s3_bucket.s3_bucket.bucket
  key          = "index.html"
  source       = "${path.module}/Resources/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/Resources/index.html")
}

resource "aws_route53_record" "route53_record" {
  count = length(local.domain_names)

  depends_on = [
    aws_cloudfront_distribution.s3_distribution
  ]

  zone_id = data.aws_route53_zone.domain_name[0].zone_id
  name    = local.domain_names[count.index]
  type    = "A"

  alias {
    name    = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id = "Z2FDTNDATAQYW2"

    //HardCoded value for CloudFront
    evaluate_target_health = false
  }
}

#tfsec:ignore:aws-cloudfront-enable-logging - logging is dynamic and triggered by input variables.
resource "aws_cloudfront_distribution" "s3_distribution" {
  aliases = local.domain_names

  depends_on = [
    aws_s3_bucket.s3_bucket
  ]

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object
  price_class         = var.price_class
  web_acl_id          = var.aws_waf_arn
  wait_for_deployment = false

  origin {
    domain_name = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    origin_id   = "s3-cloudfront-origin-identity"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
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

    target_origin_id = "s3-cloudfront-origin-identity"

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

    target_origin_id = "s3-cloudfront-origin-identity"

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
    default_ttl                = 0
    max_ttl                    = 0
    compress                   = var.compress
    path_pattern               = "/${var.default_root_object}"
  }

  dynamic "logging_config" {
    for_each = local.logging_enabled
    content {
      include_cookies = var.include_cookies
      bucket          = var.s3_log_bucket
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

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "access-identity-${var.domain_name}.s3.amazonaws.com"
}