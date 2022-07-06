# terraform-aws-s3-secure-static-website
Terraform module which creates secure s3 static website and all associated resources
<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

### Example 1 Basic 
```hcl
provider "aws" {
  region = "us-east-1"
}

module "cloudfront_s3_website_with_domain" {
    source                 = "../../"
    version                = "1.0.0"
    domain_name            = "test-application-1232" // random identifier for s3 bucket name
    use_default_domain     = true
    upload_sample_file     = true
}
```
### Example 2 Domain Name and ACM Certificate Provided
```hcl
module "cloudfront_s3_website_without_domain" {
    source                 = "../../"
    version                = "1.0.0"
    hosted_zone            = "example.com" 
    domain_name            = "test.acme.example.com"
    acm_certificate_domain = "*.acme.example.com"
    use_default_domain     = false
    upload_sample_file     = true
}
```
