terraform {
  required_version = "=0.12.24"
  backend "s3" {
    bucket = "aws-experiments-terraform-state"
    key = "default"
    region = "eu-west-1"
  }
}

provider "aws" {
  version = "2.57.0"
  region = var.aws_region
}

provider "archive" {
  version = "1.3"
}

resource "aws_s3_bucket" "aws-experiments-terraform-state" {
    bucket = "aws-experiments-terraform-state"
    versioning {
      enabled = true
    }
    lifecycle {
      prevent_destroy = true
    }
}
