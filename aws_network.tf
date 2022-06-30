
#New internet gateway for custom VPC
resource "aws_internet_gateway" "new_gateway" {
  vpc_id = "${aws_vpc.primary.id}"

  tags = {
    Name = "main_gateway"
  }
}

#Create route table in us-east-1
resource "aws_route_table" "internet_route" {
  vpc_id = "${aws_vpc.primary.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.new_gateway.id
  }
}

#Route table for new internet gateway
resource "aws_route_table_association" "rt_association" {
  subnet_id      = "${aws_subnet.test_subnet.id}"
  route_table_id = "${aws_route_table.internet_route.id}"
}

#Create a VPC
resource "aws_vpc" "primary" {
  cidr_block = "10.0.0.0/16"
}

#Create subnet for nondefault vpc
resource "aws_subnet" "test_subnet" {
  vpc_id            = "${aws_vpc.primary.id}"
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "testbox_network"
  }
}

