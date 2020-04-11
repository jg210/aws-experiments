resource "aws_s3_bucket" "aws-experiments" {
    bucket = "aws-experiments"
    versioning {
      enabled = false
    }
    lifecycle {
      prevent_destroy = true
    }
}

resource "aws_iam_user" "travis" {
  name = "travis"
}

resource "aws_iam_group" "aws-experiments-upload" {
  name = "aws-experiments-upload"
}

resource "aws_iam_group_membership" "aws-experiments-upload" {
  name = "aws-experiments-upload"
  users = [
    aws_iam_user.travis.name
  ]
  group = aws_iam_group.aws-experiments-upload.name
}

# Allow upload from https://github.com/jg210/spring-experiments/blob/master/.travis.yml
data "aws_iam_policy_document" "aws-experiments-upload" {
  statement {
    actions = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.aws-experiments.arn}/artifacts/*"]
  }
}

resource "aws_iam_group_policy" "aws-experiments-upload" {
  name = "aws-experiments-upload"
  policy = data.aws_iam_policy_document.aws-experiments-upload.json
  group = aws_iam_group.aws-experiments-upload.id
}

data "aws_iam_policy_document" "server_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aws_experiments_download" {
  name = "aws_experiments_download"
  assume_role_policy = data.aws_iam_policy_document.server_role.json
}

resource "aws_iam_instance_profile" "aws_experiments_download" {
    name = "aws_experiments_download"
    role = aws_iam_role.aws_experiments_download.name
}

# Allow download by https://github.com/jg210/aws-experiments/blob/master/resources/bin/provision when running packer.
data "aws_iam_policy_document" "aws_experiments_download" {
  statement {
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.aws-experiments.arn}/artifacts/*"]
  }
}

resource "aws_iam_role_policy" "aws_experiments_download" {
  name = "aws_experiments_download"
  policy = data.aws_iam_policy_document.aws_experiments_download.json
  role = aws_iam_role.aws_experiments_download.id
}
