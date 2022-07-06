variable "domain_name" {
  type        = string
  description = "domain name (or application name if no domain name available)"
}

variable "hosted_zone" {
  type        = string
  default     = null
  description = "Route53 hosted zone"
}

variable "acm_certificate_domain" {
  type        = string
  default     = null
  description = "Domain of the ACM certificate"
}

variable "default_root_object" {
  type        = string
  default     = "index.html"
  description = "Default root object"
}

variable "price_class" {
  type        = string
  default     = "PriceClass_100" // Only US,Canada,Europe
  description = "CloudFront distribution price class"
}

variable "geo_restrictions" {
  type        = any
  default     = []
  description = "restriction_type (Required) - The method that you want to use to restrict distribution of your content by country: none, whitelist, or blacklist. locations (Optional) - The ISO 3166-1-alpha-2 codes for which you want CloudFront either to distribute your content (whitelist) or not distribute your content (blacklist)."
}

variable "cloudfront_logs_bucket" {
  type        = string
  default     = null
  description = "S3 bucket for cloudfront logs : example-s3-access-logs"
}

variable "s3_access_logs_bucket" {
  type        = string
  default     = null
  description = "S3 bucket for logs S3 access logs : example-cloudfront-logs.s3.eu-west-1.amazonaws.com"
}

variable "include_cookies" {
  type        = bool
  default     = false
  description = "Include cookies in logs"
}

variable "aws_waf_arn" {
  type        = string
  default     = null
  description = "The ID of the AWS WAF web ACL to associate with the distribution"
}

variable "aliases" {
  type        = list(string)
  default     = []
  description = "The domain names that you want to use as aliases for the distribution"
}

variable "upload_sample_file" {
  type        = bool
  default     = false
  description = "Upload sample html file to s3 bucket"
}

variable "use_default_domain" {
  type        = bool
  default     = false
  description = "Use default domain name"
}

variable "aws_cloudfront_response_headers_policy_id" {
  type        = string
  default     = null
  description = "Arn of the response headers policy to add to the distribution"
}

variable "compress" {
  type        = bool
  default     = true
  description = "Enable gzip compression"
}

variable "lambda_function_associations" {
  type = list(object({
    lambda_arn   = string
    event_type   = string
    include_body = bool
  }))
  default     = []
  description = "The IDs of the Lambda functions to associate with the distribution"
}

variable "tags" {
  default = {
    Name = "my-secure-s3-static-site"
  }
  type        = map(string)
  description = "(Optional) Map of key-value resource tags to associate with the resource. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
}