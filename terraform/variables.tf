variable "public_key_path" {
  description = "Path to the SSH public key to be used for authentication."
  default = "~/.ssh/aws-experiments.pub"
}

variable "key_name" {
  description = "AWS key-pair name."
  default = "aws-experiments"
}

variable "aws_region" {
  description = "AWS region."
  default = "eu-west-1"
}

variable "amis" {
  description = "AMI images."
  default = {
    eu-west-1 = "ami-035966e8adab4aaad"
  }
}

variable "domain" {
  default = "jeremygreen.me.uk"
}

variable "subdomain_ec2" {
  default = "spring-experiments"
}

variable "subdomain_api" {
  default = "aws"
}
