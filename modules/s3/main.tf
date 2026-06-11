resource "random_id" "suffix" {
  byte_length = 4
}

# ---------- KMS key for bucket encryption (CKV_AWS_145) ----------

resource "aws_kms_key" "s3" {
  description             = "KMS key for ${var.project} S3 bucket"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = { Name = "${var.project}-s3-kms" }
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.project}-s3"
  target_key_id = aws_kms_key.s3.key_id
}

# ---------- Main bucket ----------

resource "aws_s3_bucket" "this" {
  bucket = "${var.project}-${random_id.suffix.hex}"

  tags = { Name = "${var.project}-bucket" }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---------- Access logging (CKV_AWS_18) ----------

resource "aws_s3_bucket" "logs" {
  #checkov:skip=CKV_AWS_18:Log bucket does not log itself (circular)
  #checkov:skip=CKV_AWS_144:Log bucket does not need cross-region replication
  #checkov:skip=CKV2_AWS_62:Log bucket does not need event notifications
  bucket = "${var.project}-logs-${random_id.suffix.hex}"

  tags = { Name = "${var.project}-log-bucket" }
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "expire-old-logs"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_logging" "this" {
  bucket        = aws_s3_bucket.this.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "access-logs/"
}

# ---------- Lifecycle configuration (CKV2_AWS_61) ----------

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "transition-and-expire"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# ---------- Event notifications via SNS (CKV2_AWS_62) ----------

data "aws_caller_identity" "current" {}

resource "aws_sns_topic" "s3_events" {
  name              = "${var.project}-s3-events"
  kms_master_key_id = "alias/aws/sns"

  tags = { Name = "${var.project}-s3-events" }
}

data "aws_iam_policy_document" "sns_policy" {
  statement {
    sid       = "AllowS3Publish"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.s3_events.arn]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.this.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_sns_topic_policy" "s3_events" {
  arn    = aws_sns_topic.s3_events.arn
  policy = data.aws_iam_policy_document.sns_policy.json
}

resource "aws_s3_bucket_notification" "this" {
  bucket = aws_s3_bucket.this.id

  topic {
    topic_arn = aws_sns_topic.s3_events.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }

  depends_on = [aws_sns_topic_policy.s3_events]
}

# ---------- Cross-region replication (CKV_AWS_144) ----------

resource "aws_kms_key" "replica" {
  provider                = aws.replica
  description             = "KMS key for ${var.project} S3 replica bucket"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = { Name = "${var.project}-s3-replica-kms" }
}

resource "aws_s3_bucket" "replica" {
  #checkov:skip=CKV_AWS_18:Replica bucket does not need its own access logging
  #checkov:skip=CKV_AWS_144:Replica is the replication destination — no further replication needed
  #checkov:skip=CKV2_AWS_62:Replica bucket does not need event notifications
  provider = aws.replica
  bucket   = "${var.project}-replica-${random_id.suffix.hex}"

  tags = { Name = "${var.project}-replica-bucket" }
}

resource "aws_s3_bucket_versioning" "replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.replica.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica.id

  rule {
    id     = "expire-noncurrent"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

data "aws_iam_policy_document" "replication_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "replication" {
  name               = "${var.project}-s3-replication-role"
  assume_role_policy = data.aws_iam_policy_document.replication_assume.json

  tags = { Name = "${var.project}-s3-replication-role" }
}

data "aws_iam_policy_document" "replication" {
  statement {
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]
    resources = [aws_s3_bucket.this.arn]
  }

  statement {
    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }

  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]
    resources = ["${aws_s3_bucket.replica.arn}/*"]
  }

  statement {
    sid       = "DecryptSource"
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_key.s3.arn]
  }

  statement {
    sid       = "EncryptReplica"
    actions   = ["kms:Encrypt"]
    resources = [aws_kms_key.replica.arn]
  }
}

resource "aws_iam_role_policy" "replication" {
  name   = "${var.project}-s3-replication"
  role   = aws_iam_role.replication.id
  policy = data.aws_iam_policy_document.replication.json
}

resource "aws_s3_bucket_replication_configuration" "this" {
  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "replicate-all"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.replica.arn
      storage_class = "STANDARD_IA"

      encryption_configuration {
        replica_kms_key_id = aws_kms_key.replica.arn
      }
    }

    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}
