terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "ap-south-1"
}

resource "aws_instance" "instance" {
  instance_type   = var.instance_type
  subnet_id       = var.subnet
  ami             = var.ami
  key_name        = var.key_pairs_name
  security_groups = ["${aws_security_group.allow_tls.id}"]

  # user_data = file("${path.module}/apache.sh")
      connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/mumbai-airflow.pem")
      host        = "${self.public_ip}"
    }

# file provisioner is used to transfer files and directories from local machine to remote machine on cloud.
  provisioner "file" {
    source      = "README.md"
    destination = "/tmp/README.md"
  }
  provisioner "file" {
    source = "source-code"
    destination = "/tmp/source-code"
  }
  # local-exec provisioner is used to run commands on local machine where terraform is installed.
  provisioner "local-exec" {
    on_failure = continue
    command = "echo ${self.public_ip}"
  }
  provisioner "local-exec" {
    when = destroy
    command = "echo 'at delete'"
  
  }
# remote-exec provisioner is used to run commands and shell scripts on remote machine.
  provisioner "remote-exec" {
    script = "./apache.sh"
  }

}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/24"
  tags = {
    "Name" = "My-vpc-demo"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-0bf65fe0cdaf85ad2"

  dynamic "ingress" {
    for_each = [80, 443, 22]
    iterator = port
    content {
      description = "TLS from VPC"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}
