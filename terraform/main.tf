terraform {
  required_version = "=0.12.9"
  backend "s3" {
    bucket = "aws-experiments-terraform-state"
    key = "default"
    region = "eu-west-1"
  }
}

provider "aws" {
  version = "2.30.0"
  region = "${var.aws_region}"
}

# module "vpc" {
#   source = "./vpc"
# }
#
# module "artifacts" {
#   source = "./artifacts"
# }
#
# module "ec2" {
#   source = "./ec2"
# }
