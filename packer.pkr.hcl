packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "1.2.8"
    }
  }
}

variable "aws_access_key" {
  type    = string
  default = ""
}

variable "aws_ami_name" {
  type    = string
  default = "packer-aws-experiments"
}

variable "aws_instance_type" {
  type    = string
  default = "t2.nano"
}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "aws_secret_key" {
  type    = string
  default = ""
}

data "amazon-ami" "ami" {
  access_key = "${var.aws_access_key}"
  filters = {
    name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = "${var.aws_region}"
  secret_key  = "${var.aws_secret_key}"
}

source "amazon-ebs" "ebs" {
  access_key           = "${var.aws_access_key}"
  ami_name             = "${var.aws_ami_name}"
  iam_instance_profile = "aws_experiments_download"
  instance_type        = "${var.aws_instance_type}"
  region               = "${var.aws_region}"
  secret_key           = "${var.aws_secret_key}"
  source_ami           = "${data.amazon-ami.ami.id}"
  ssh_username         = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.ebs"]

  provisioner "shell" {
    script = "./resources/bin/provision"
  }

}
