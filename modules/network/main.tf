terraform { 
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name_prefix}-igw"
  }

}

data "aws_availability_zones" "this" {
  state = "available"
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.this.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.this.names[0]

  tags = {
    Name = "${var.name_prefix}-subnet"
  }

}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "this" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


resource "aws_security_group" "this" {
  name = "${var.name_prefix}-sg"
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name_prefix}-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "this" {
    security_group_id = aws_security_group.this.id
    ip_protocol = -1
    cidr_ipv4  = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "this" {
    security_group_id = aws_security_group.this.id
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr_ipv4  = "0.0.0.0/0"
}
