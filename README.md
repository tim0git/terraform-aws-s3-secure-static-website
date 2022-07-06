# terraform-aws-s3-secure-static-website
Terraform module which creates secure s3 static website and all associated resources
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_aws.aws_cloudfront"></a> [aws.aws\_cloudfront](#provider\_aws.aws\_cloudfront) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.s3_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.origin_access_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_route53_record.route53_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_policy.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_object.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_acm_certificate.acm_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |
| [aws_iam_policy_document.s3_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.domain_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_domain"></a> [acm\_certificate\_domain](#input\_acm\_certificate\_domain) | Domain of the ACM certificate | `string` | `null` | no |
| <a name="input_aliases"></a> [aliases](#input\_aliases) | The domain names that you want to use as aliases for the distribution | `list(string)` | `[]` | no |
| <a name="input_aws_cloudfront_response_headers_policy_id"></a> [aws\_cloudfront\_response\_headers\_policy\_id](#input\_aws\_cloudfront\_response\_headers\_policy\_id) | Arn of the response headers policy to add to the distribution | `string` | `null` | no |
| <a name="input_aws_waf_arn"></a> [aws\_waf\_arn](#input\_aws\_waf\_arn) | The ID of the AWS WAF web ACL to associate with the distribution | `string` | `null` | no |
| <a name="input_compress"></a> [compress](#input\_compress) | Enable gzip compression | `bool` | `true` | no |
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | Default root object | `string` | `"index.html"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | domain name (or application name if no domain name available) | `string` | n/a | yes |
| <a name="input_geo_restrictions"></a> [geo\_restrictions](#input\_geo\_restrictions) | restriction\_type (Required) - The method that you want to use to restrict distribution of your content by country: none, whitelist, or blacklist. locations (Optional) - The ISO 3166-1-alpha-2 codes for which you want CloudFront either to distribute your content (whitelist) or not distribute your content (blacklist). | `any` | `[]` | no |
| <a name="input_hosted_zone"></a> [hosted\_zone](#input\_hosted\_zone) | Route53 hosted zone | `string` | `null` | no |
| <a name="input_include_cookies"></a> [include\_cookies](#input\_include\_cookies) | Include cookies in logs | `bool` | `false` | no |
| <a name="input_lambda_function_associations"></a> [lambda\_function\_associations](#input\_lambda\_function\_associations) | The IDs of the Lambda functions to associate with the distribution | <pre>list(object({<br>    lambda_arn = string<br>    event_type = string<br>    include_body = bool<br>  }))</pre> | `[]` | no |
| <a name="input_price_class"></a> [price\_class](#input\_price\_class) | CloudFront distribution price class | `string` | `"PriceClass_100"` | no |
| <a name="input_s3_log_bucket"></a> [s3\_log\_bucket](#input\_s3\_log\_bucket) | S3 bucket for logs | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Map of key-value resource tags to associate with the resource. If configured with a provider default\_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level. | `map(string)` | <pre>{<br>  "Name": "my-secure-s3-static-site"<br>}</pre> | no |
| <a name="input_upload_sample_file"></a> [upload\_sample\_file](#input\_upload\_sample\_file) | Upload sample html file to s3 bucket | `bool` | `false` | no |
| <a name="input_use_default_domain"></a> [use\_default\_domain](#input\_use\_default\_domain) | Use default domain name | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_dist_id"></a> [cloudfront\_dist\_id](#output\_cloudfront\_dist\_id) | n/a |
| <a name="output_cloudfront_domain_name"></a> [cloudfront\_domain\_name](#output\_cloudfront\_domain\_name) | n/a |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | n/a |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | n/a |
| <a name="output_s3_domain_name"></a> [s3\_domain\_name](#output\_s3\_domain\_name) | n/a |
| <a name="output_website_address"></a> [website\_address](#output\_website\_address) | n/a |
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
