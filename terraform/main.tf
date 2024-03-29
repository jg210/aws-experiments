terraform {
  required_version = "=1.5.6"
  required_providers {
    archive = {
      source = "hashicorp/archive"
      version = "2.4.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "5.14.0"
    }
  }
  backend "s3" {
    bucket = "aws-experiments-terraform-state"
    key = "default"
    region = "eu-west-1"
  }
}

provider "archive" {
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "aws-experiments-terraform-state" {
    bucket = "aws-experiments-terraform-state"
    lifecycle {
      prevent_destroy = true
    }
}

resource "aws_s3_bucket_versioning" "aws-experiments-terraform-state" {
  bucket = aws_s3_bucket.aws-experiments-terraform-state.id
  versioning_configuration {
    status = "Suspended"
  }
}
