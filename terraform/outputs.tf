output "address" {
  value = "${aws_eip.server.public_ip}"
  description = "The server's public IP address."
}
