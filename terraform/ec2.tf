resource "aws_key_pair" "auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

data "aws_ami" "server" {
  owners = ["self"]
  filter {
    name   = "name"
    values = ["packer-aws-experiments"]
  }
}

resource "aws_instance" "server" {
  connection {
    user = "ubuntu"
    host = self.public_ip
  }
  instance_type = "t2.nano"
  ami = data.aws_ami.server.image_id
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.default.id]
  subnet_id = aws_subnet.primary.id
}

resource "aws_eip" "server" {
  domain = "vpc"
  instance = aws_instance.server.id
  depends_on = [aws_internet_gateway.default]
  provisioner "local-exec" {
    command = "curl --verbose --data-urlencode \"domain=${var.domain}\" --data-urlencode \"password@$${HOME}/.dns-api-password\" --data-urlencode \"command=REPLACE ${var.subdomain_ec2} 60 A ${aws_eip.server.public_ip}\" \"$(cat $${HOME}/.dns-api-url)\""
  }
}
