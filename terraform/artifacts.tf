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

resource "aws_iam_role" "server" {
  name = "server_role"
  assume_role_policy = data.aws_iam_policy_document.server_role.json
}

resource "aws_iam_instance_profile" "server" {
    name = "server"
    role = aws_iam_role.server.name
}

# Allow download by https://github.com/jg210/aws-experiments/blob/master/resources/bin/provision
data "aws_iam_policy_document" "aws-experiments-download" {
  statement {
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.aws-experiments.arn}/artifacts/*"]
  }
}

resource "aws_iam_role_policy" "aws-experiments-download" {
  name = "aws-experiments-download"
  policy = data.aws_iam_policy_document.aws-experiments-download.json
  role = aws_iam_role.server.id
}
