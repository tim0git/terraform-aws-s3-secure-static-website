locals {
  cloudfront_logging_enabled       = var.cloudfront_logs_bucket != null ? [{}] : []
  s3_bucket_access_logging_enabled = var.s3_access_logs_bucket != null ? true : false
  geo_restrictions_enabled         = var.geo_restrictions != [] ? [{}] : []
  geo_restrictions_disabled        = var.geo_restrictions != [] ? [] : [{}]
  default_certs                    = var.use_default_domain ? ["default"] : []
  acm_certs                        = var.use_default_domain ? [] : ["acm"]
  domain_names                     = concat([var.domain_name], var.aliases)
  create_route53_records           = var.use_default_domain ? false : true
  s3_bucket_key_alias              = "alias/${replace(var.domain_name, ".", "-")}"
}

provider "aws" {
  region  = "us-east-1"
  alias   = "aws_cloudfront"
  profile = var.aws_profile
}
