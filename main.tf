terraform {
  required_version = "=0.11.13"
  backend "s3" {
    bucket = "aws-experiments-terraform-state"
    key = "default"
    region = "eu-west-1"
  }
}

provider "aws" {
  version = "2.2.0"
  region = "${var.aws_region}"
}

data "aws_availability_zones" "available" {}

resource "aws_s3_bucket" "aws-experiments-terraform-state" {
    bucket = "aws-experiments-terraform-state"
    versioning {
      enabled = true
    }
    lifecycle {
      prevent_destroy = true
    }
}

resource "aws_s3_bucket" "aws-experiments" {
    bucket = "aws-experiments"
    versioning {
      enabled = false
    }
    lifecycle {
      prevent_destroy = true
    }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route" "internet" {
  route_table_id = "${aws_vpc.main.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "primary" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
}

resource "aws_security_group" "default" {
  name        = "security_group"
  description = "security group"
  vpc_id      = "${aws_vpc.main.id}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "server" {
  connection {
    user = "ubuntu"
  }
  instance_type = "t2.micro"
  ami = "${lookup(var.amis, var.aws_region)}"
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.primary.id}"
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx"
    ]
  }
}

resource "aws_eip" "server" {
  vpc = true
  instance = "${aws_instance.server.id}"
  depends_on = ["aws_internet_gateway.default"]
}

