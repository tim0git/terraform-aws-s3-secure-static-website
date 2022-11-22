resource "aws_route53_record" "this" {
  count = local.create_route53_records ? length(local.domain_names) : 0

  depends_on = [
    aws_cloudfront_distribution.this
  ]

  zone_id = data.aws_route53_zone.domain_name[0].zone_id
  name    = local.domain_names[count.index]
  type    = "A"

  alias {
    name    = aws_cloudfront_distribution.this.domain_name
    zone_id = "Z2FDTNDATAQYW2"
    //HardCoded value for CloudFront
    evaluate_target_health = false
  }
}
