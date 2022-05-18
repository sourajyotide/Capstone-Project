#vpc
resource "aws_vpc" "vpc" {
  cidr_block       = "10.100.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "demo-vpc"
  }
  enable_dns_hostnames = true
}

#public subnet 1
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.100.1.0/24"

  tags = {
    Name = "public-subnet-1"
    #kubernetes.io/cluster/cluster-name = shared
    #kubernetes.io/role/elb = 1
  }

  map_public_ip_on_launch = true
}
#public subnet 2
resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.100.2.0/24"

  tags = {
    Name = "public-subnet-2"
    #kubernetes.io/cluster/cluster-name = shared
    #kubernetes.io/role/elb = 1
  }

  map_public_ip_on_launch = true
}

#private subnet
resource "aws_subnet" "private_subnet_1" {

  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.100.11.0/24"

  tags = {
    Name = "private-subnet-1"
    #kubernetes.io/cluster/cluster-name = shared
    #kubernetes.io/role/internal-elb = 1
  }
}
resource "aws_subnet" "private_subnet_2" {

  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.100.12.0/24"

  tags = {
    Name = "private-subnet-2"
    #kubernetes.io/cluster/cluster-name = shared
    #kubernetes.io/role/internal-elb = 1
  }
}

resource "aws_internet_gateway" "internet_gateway" {

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internet-gateway"
  }
}

resource "aws_eip" "elastic_ip" {
  vpc      = true
}

#NAT gateway
resource "aws_nat_gateway" "nat_gateway" {

  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "nat-gateway"
  }
}

resource "aws_route_table" "IG_route_table" {

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "IG-route-table"
  }
}

#associate route table to the public subnet
resource "aws_route_table_association" "associate_routetable_to_public_subnet_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.IG_route_table.id
}
resource "aws_route_table_association" "associate_routetable_to_public_subnet_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.IG_route_table.id
}
resource "aws_route_table" "NAT_route_table" {

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "NAT-route-table"
  }
}

#associate route table to private subnet
resource "aws_route_table_association" "associate_routetable_to_private_subnet_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.NAT_route_table.id
}
resource "aws_route_table_association" "associate_routetable_to_private_subnet_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.NAT_route_table.id
}
