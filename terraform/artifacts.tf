resource "aws_s3_bucket" "aws-experiments" {
    #checkov:skip=CKV_AWS_21:don't need versioning
    #checkov:skip=CKV_AWS_144:don't want cross-region replication
    #checkov:skip=CKV2_AWS_61:don't need lifecycle management and don't want expiry
    #checkov:skip=CKV2_AWS_62:don't want event notification
    #checkov:skip=CKV_AWS_18:don't want logging
    bucket = "aws-experiments"
    lifecycle {
      prevent_destroy = true
    }
}

resource "aws_s3_bucket_public_access_block" "access-aws-experiments" {
  bucket = aws_s3_bucket.aws-experiments.id
  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls=true
}

resource "aws_s3_bucket_versioning" "aws-experiments" {
  bucket = aws_s3_bucket.aws-experiments.id
  versioning_configuration {
    status = "Suspended"
  }
}

resource "aws_iam_user" "gha" {
  name = "gha"
}

resource "aws_iam_group" "aws-experiments-upload" {
  name = "aws-experiments-upload"
}

resource "aws_iam_group_membership" "aws-experiments-upload" {
  name = "aws-experiments-upload"
  users = [
    aws_iam_user.gha.name
  ]
  group = aws_iam_group.aws-experiments-upload.name
}

# Allow upload from https://github.com/jg210/spring-experiments
data "aws_iam_policy_document" "aws-experiments-upload" {
  statement {
    actions = ["s3:PutObject", "s3:GetObject"]
    resources = ["${aws_s3_bucket.aws-experiments.arn}/artifacts/*"]
  }
  statement {
    actions = ["s3:ListBucket"]
    resources = [aws_s3_bucket.aws-experiments.arn]
  }
}
resource "aws_iam_group_policy" "aws-experiments-upload" {
  name = "aws-experiments-upload"
  policy = data.aws_iam_policy_document.aws-experiments-upload.json
  group = aws_iam_group.aws-experiments-upload.id
}

# Allow download by e.g. lambda (the aws_iam_role_policy_attachments are configured elsewhere).
data "aws_iam_policy_document" "aws_experiments_download" {
  statement {
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.aws-experiments.arn}/artifacts/*"]
  }
}
resource "aws_iam_policy" "aws_experiments_download" {
  name = "aws_experiments_download"
  policy = data.aws_iam_policy_document.aws_experiments_download.json
}
