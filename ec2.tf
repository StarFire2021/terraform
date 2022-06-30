#Port variable for security group
variable "ingressrules" {
  type    = list(number)
  default = [80, 443, 22]
}

#Security group for EC2 instance to allow web traffic on ports 80, 443, and 22
resource "aws_security_group" "web_traffic" {
  name        = "Allow web traffic"
  description = "Allow ssh and standard http/https ports inbound and everything outbound"
  vpc_id = "${aws_vpc.primary.id}"

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
resource "aws_instance" "testbox" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  subnet_id = "${aws_subnet.test_subnet.id}"
  private_ip = "10.0.0.4"
  vpc_security_group_ids = ["${aws_security_group.web_traffic.id}"]

  tags = {
    Name = "Testbox"
  }
}

#Data about ami version for EC2 instance
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}





