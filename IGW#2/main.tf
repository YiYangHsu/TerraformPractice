provider "aws" {
    region = "us-east-1"
}

# create vpc - demo_vpc
resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"
}

# create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.demo_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch =  true
  availability_zone = "us-east-1a"
  depends_on = [ aws_vpc.demo_vpc ]
  tags = {
    Name = "public_subnet"
  }
}

# create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.demo_vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch =  false
  availability_zone = "us-east-1b"
  depends_on = [ aws_vpc.demo_vpc ]
  tags = {
    Name = "private_subnet"
  }
}

# define routing table for public routing table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.demo_vpc.id
  tags = {
    Name = "routing table for pulic subnet"
  }
}

# associate subnet with routing table
resource "aws_route_table_association" "public_route_assicate" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.my_route_table.id
}

# Internet gateway for Internet
resource "aws_internet_gateway" "demo_IGW" {
  vpc_id = aws_vpc.demo_vpc.id
  depends_on = [ aws_vpc.demo_vpc ]
}

# Add default route in routing table and point ot Internet Gateway
resource "aws_route" "default_route" {
  route_table_id = aws_route_table.my_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.demo_IGW.id
}

