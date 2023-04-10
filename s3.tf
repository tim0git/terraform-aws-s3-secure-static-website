resource "aws_s3_bucket" "this" {
  bucket = var.domain_name
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "this" {
  count        = var.upload_sample_file ? 1 : 0
  bucket       = aws_s3_bucket.this.bucket
  key          = "index.html"
  source       = "${path.module}/Resources/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/Resources/index.html")
}

resource "aws_s3_bucket_logging" "this" {
  count  = local.s3_bucket_access_logging_enabled ? 1 : 0
  bucket = aws_s3_bucket.this.id

  target_bucket = var.s3_access_logs_bucket
  target_prefix = "s3-access-logs/${var.domain_name}"
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}
