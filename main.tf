locals {
  unique_name = "${var.name}-${var.id}"
}

resource "aws_s3_bucket" "bucket" {
  acl           = var.bucket_acl
  bucket        = local.unique_name
  force_destroy = var.force_destroy

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_master_key_id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning {
    enabled = var.bucket_versioning
  }

  lifecycle_rule {
    id      = "${local.unique_name}-${var.lifecycle_rule_expiration_days}days-expiration"
    enabled = var.lifecycle_rule_enabled

    expiration {
      days = var.lifecycle_rule_expiration_days
    }

    noncurrent_version_expiration {
      days = var.lifecycle_rule_noncurrent_version_expiration
    }
  }

  tags = var.tags
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = local.unique_name
  count  = var.use_bucket_policy ? 1 : 0
  policy = var.bucket_policy
}

resource "aws_s3_bucket_public_access_block" "public" {
  depends_on          = [aws_s3_bucket_policy.policy]
  bucket              = aws_s3_bucket.bucket.id
  block_public_acls   = var.block_public_acls
  block_public_policy = var.block_public_policy
}

