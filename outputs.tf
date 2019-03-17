output "address" {
  value = "${aws_eip.server.public_ip}"
}
