terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20"
    }
  }
}

#Configure the AWS Provider
provider "aws" {

}

#Port variable for security group
variable "ingressrules" {
  type    = list(number)
  default = [80, 443, 22]
}

#Security group for EC2 instance to allow web traffic on ports 80, 443, and 22
resource "aws_security_group" "web_traffic" {
  name        = "Allow web traffic"
  description = "Allow ssh and standard http/https ports inbound and everything outbound"
  vpc_id      = data.aws_vpc.default.id

  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create EC2 instance
resource "aws_instance" "ansible-1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  subnet_id              = data.aws_subnet.primary.id
  private_ip             = "172.31.0.4"
  vpc_security_group_ids = ["${aws_security_group.web_traffic.id}"]

  user_data = <<EOF
  #!/bin/bash
  echo "Updating repos"
  yum -y update
  echo "Installing Python3"
  yum install -y python3
  echo "Adding ansible user"
  useradd -m -p vagrant -s /bin/bash ansible
  gpasswd -a ansible wheel
  EOF

  tags = {
    Name = "ansible-1"
  }
}

#Data about ami version for EC2 instance
data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "image-id"
    values = ["ami-05fa00d4c63e32376"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#Network Section

#Terraform adopting default VPC
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

#Pulling default subnet data for use with instances
data "aws_vpc" "default" {
    default = true
}

variable "subnet_id" {
  
}

data "aws_subnet" "primary" {
  vpc_id = data.aws_vpc.default.id
  id = var.subnet_id
}