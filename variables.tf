variable "domain_name" {
  default = ""
  type = string
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

variable "web_acl_id" {
  type        = string
  default     = null
  description = "The ID of the AWS WAF web ACL to associate with the distribution"
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

variable "tags" {
  default = {
    Name = "my-secure-s3-static-site"
  }
  type        = map(string)
  description = "(Optional) Map of key-value resource tags to associate with the resource. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
}