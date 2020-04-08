provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "pact-broker" {
  name        = "pact-broker"
  description = "pact broker ui and ssh"

  /*vpc_id = "${var.aws_vpc}"*/

  // These are for internal traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // These are for maintenance
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pact broker security group"
  }
}

resource "aws_instance" "server" {
  ami             = var.aws_ami
  instance_type   = "t2.small"
  count           = 1
  security_groups = [aws_security_group.pact-broker.name]
  key_name        = "PactKeyPair"

  associate_public_ip_address = "true"

  tags = {
    Name = "pact-broker"
  }

  connection {
    host = coalesce(self.public_ip, self.private_ip)
    type = "ssh"
    user = "ubuntu"
    private_key = file("${path.module}/ssh/id_rsa")
    timeout = "1m"
  }

  provisioner "file" {
    source      = "${path.module}/templates/nginx.conf"
    destination = "/tmp/nginx.conf"
  }

  provisioner "file" {
    source      = "${path.module}/templates/pact-broker.sh"
    destination = "/tmp/pact-broker.sh"
  }

  provisioner "file" {
    source      = "${path.module}/templates/config.ru"
    destination = "/tmp/config.ru"
  }

  provisioner "file" {
    source      = "${path.module}/templates/Gemfile"
    destination = "/tmp/Gemfile"
  }

  provisioner "file" {
    source      = "${path.module}/templates/pact-broker.service"
    destination = "/tmp/pact-broker.service"
  }

  provisioner "file" {
    source      = "${path.module}/templates/nginx.service"
    destination = "/tmp/nginx.service"
  }

  # use this until files can be templated
  # use this until files can be templated
  provisioner "remote-exec" {
    inline = [
      "echo 'export DB_HOST=${var.db_host}' >> /tmp/postgres_vars",
      "echo 'export DB_NAME=${var.db_name}' >> /tmp/postgres_vars",
      "echo 'export DB_USERNAME=${var.db_username}' >> /tmp/postgres_vars",
      "echo 'export DB_PASSWORD=${var.db_password}' >> /tmp/postgres_vars",
      "echo 'export DB_URL=postgres://$DB_USERNAME:$DB_PASSWORD@$DB_HOST/$DB_NAME' >> /tmp/postgres_vars",
    ]
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/install.sh",
      "${path.module}/scripts/server.sh",
      "${path.module}/scripts/service.sh",
    ]
  }
}

resource "aws_eip" "lb" {
  instance = aws_instance.server[0].id
  vpc      = true
}