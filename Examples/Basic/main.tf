provider "aws" {
  region = "eu-west-1"
}

resource "random_uuid" "test" {
} // required for test only

module "cloudfront_s3_website_with_default_domain" {
  source                 = "../../"
  version                = "1.0.0"
  domain_name            = "test-${random_uuid.test.result}" //  random identifier for s3 bucket name
  use_default_domain     = true
  upload_sample_file     = true
}