terraform {
  required_version = "=0.15.1"
  required_providers {
    archive = {
      source = "hashicorp/archive"
      version = "1.3"
    }
    aws = {
      source = "hashicorp/aws"
      version = "3.38.0"
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
    versioning {
      enabled = true
    }
    lifecycle {
      prevent_destroy = true
    }
}
