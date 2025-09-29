terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.region
}

# Security group for instance access
resource "aws_security_group" "instance_access" {
  name_prefix = "instance-access-"
  description = "Allow SSH and additional port access"

  # SSH access
  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }

  # Additional ports (HTTP, HTTPS, custom apps)
  dynamic "ingress" {
    for_each = var.additional_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}

# Generate private key
resource "tls_private_key" "keypair" {
  count     = var.create_keypair ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair
resource "aws_key_pair" "keypair" {
  count      = var.create_keypair ? 1 : 0
  key_name   = var.key_name
  public_key = tls_private_key.keypair[0].public_key_openssh
}

# Save private key to local file
resource "local_file" "private_key" {
  count           = var.create_keypair ? 1 : 0
  content         = tls_private_key.keypair[0].private_key_pem
  filename        = "${var.key_name}.pem"
  file_permission = "0400"
}



data "aws_ami" "selected" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "instances" {
  for_each = var.instances

  ami                    = var.ami_id != null ? var.ami_id : data.aws_ami.selected.id
  instance_type          = var.instance_type
  key_name               = var.create_keypair ? aws_key_pair.keypair[0].key_name : var.key_name
  vpc_security_group_ids = [aws_security_group.instance_access.id]
  private_ip             = each.value.private_ip

  tags = {
    Name = each.value.name
  }
}