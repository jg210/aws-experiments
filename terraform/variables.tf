variable "aws_region" {
  description = "AWS region."
  default = "eu-west-1"
  type = string
}

variable "domain" {
  default = "jeremygreen.me.uk"
  type = string
}

variable "subdomain_api" {
  default = "aws"
  type = string
}
