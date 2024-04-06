terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# Canonical, Ubuntu, 22.04 LTS, arm64 jammy image
data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

data "template_file" "init" {
  template = "${file("cloud-init.tpl.yaml")}"
  vars = {
    tailscale_authkey = var.tailscale_authkey
  }
}

resource "aws_vpc" "default" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "default" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
}

resource "aws_security_group" "default" {
  name   = "allow-ssh-icmp"
  vpc_id = aws_vpc.default.id
}

resource "aws_security_group_rule" "in_ssh" {
  security_group_id = aws_security_group.default.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

resource "aws_security_group_rule" "in_icmp" {
  security_group_id = aws_security_group.default.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
}

resource "aws_security_group_rule" "out_all" {
  security_group_id = aws_security_group.default.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
}

resource "aws_route_table_association" "default" {
  subnet_id      = aws_subnet.default.id
  route_table_id = aws_route_table.default.id
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "${file(var.aws_public_key_filename)}"
}

resource "aws_spot_instance_request" "worker" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "c6gn.medium"
  spot_type              = "persistent"
  key_name               = "deployer-key"
  wait_for_fulfillment   = true

  security_groups = [aws_security_group.default.id]
  subnet_id       = aws_subnet.default.id
  user_data       = data.template_file.init.rendered
}

resource "aws_eip" "default" {
  domain = "vpc"
  instance = aws_spot_instance_request.worker.spot_instance_id
}
