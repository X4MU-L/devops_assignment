resource "aws_s3_bucket" "storage" {
  bucket = "${var.bucket_name_prefix}-${var.resource_suffix}"

  tags = merge(
    var.tags,
    {
      Name        = "${var.bucket_name_prefix}-${var.resource_suffix}"
      Environment = var.environment
      Purpose     = var.purpose
    }
  )
}

resource "aws_s3_bucket_versioning" "storage_versioning" {
  bucket = aws_s3_bucket.storage.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "storage_lifecycle" {
  bucket = aws_s3_bucket.storage.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      filter {
        prefix = rule.value.prefix
      }

      expiration {
        days = rule.value.expiration_days
      }

      noncurrent_version_expiration {
        noncurrent_days = rule.value.noncurrent_expiration_days
      }
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "storage_encryption" {
  bucket = aws_s3_bucket.storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "storage_public_access" {
  bucket = aws_s3_bucket.storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
