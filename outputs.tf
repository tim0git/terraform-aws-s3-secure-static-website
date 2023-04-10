output "cloudfront_domain_name" {
  description = "CloudFront Domain Name"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "cloudfront_dist_id" {
  description = "CloudFront Distribution ID"
  value       = aws_cloudfront_distribution.this.id
}

output "s3_domain_name" {
  description = "S3 Domain Name"
  value       = aws_s3_bucket_website_configuration.this.website_domain
}

output "website_address" {
  description = "Website Domain Name"
  value       = var.domain_name
}

output "s3_bucket_arn" {
  description = "S3 Bucket ARN"
  value       = aws_s3_bucket.this.arn
}

output "s3_bucket_name" {
  description = "S3 Bucket Name"
  value       = aws_s3_bucket.this.id
}

