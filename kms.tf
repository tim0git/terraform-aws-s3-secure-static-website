resource "aws_kms_key" "this" {
  description             = "This key is used to encrypt ${var.domain_name} bucket data"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_key_policy.json
}

resource "aws_kms_alias" "this" {
  name          = local.s3_bucket_key_alias
  target_key_id = aws_kms_key.this.key_id
}
