data "aws_acm_certificate" "acm_cert" {
  count    = var.use_default_domain ? 0 : 1
  domain   = coalesce(var.acm_certificate_domain, "*.${var.hosted_zone}")
  provider = aws.aws_cloudfront
  statuses = [
    "ISSUED",
  ]
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid = "1"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.domain_name}/*",
    ]

    principals {
      type = "AWS"

      identifiers = [
        aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn,
      ]
    }
  }
}

data "aws_route53_zone" "domain_name" {
  count        = var.use_default_domain ? 0 : 1
  name         = var.hosted_zone
  private_zone = false
}