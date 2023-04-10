data "aws_caller_identity" "current" {}

data "aws_acm_certificate" "acm_cert" {
  count    = var.use_default_domain ? 0 : 1
  domain   = coalesce(var.acm_certificate_domain, "*.${var.hosted_zone}")
  provider = aws.aws_cloudfront
  statuses = [
    "ISSUED",
  ]
}

data "aws_route53_zone" "domain_name" {
  count        = var.use_default_domain ? 0 : 1
  name         = var.hosted_zone
  private_zone = false
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid = "AllowCloudFrontServicePrincipalReadOnly"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.domain_name}/*",
    ]

    principals {
      type = "Service"
      identifiers = [
        "cloudfront.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [
        aws_cloudfront_distribution.this.arn,
      ]
    }
  }
}

data "aws_cloudfront_cache_policy" "managed_caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "managed_caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "managed_s3_origin_cors" {
  name = "Managed-CORS-S3Origin"
}
