data "aws_region" "current" {}

locals {
   cidr_block           = "10.0.0.0/16" 
   azs = formatlist("${data.aws_region.current.name}%s", var.availability_zones)
}
/*==== The VPC ======*/
resource "aws_vpc" "vpc" {
  cidr_block           = local.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
}
/*==== Subnets ======*/

/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  for_each                = toset(local.azs)
  cidr_block = cidrsubnet(
    local.cidr_block,
    5,
    length(local.azs) + index(local.azs, each.value),
  )
  availability_zone       = each.value
  map_public_ip_on_launch = false
}


/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
}
resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private_subnet
  route_table_id = aws_route_table.private.id
  subnet_id      = each.value.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}

/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
   subnet_id= aws_subnet.public_subnet[element(keys(aws_subnet.public_subnet), 0)].id
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        = "nat"
    Environment = "${var.environment}"
  }
}

/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  for_each                =  toset(local.azs)
  cidr_block = cidrsubnet(
    local.cidr_block,8,
    length(local.azs) + index(local.azs, each.value),
  ) 
  availability_zone       =  each.value
  map_public_ip_on_launch = true

}
/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

}

/* Route table associations */
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public_subnet
  route_table_id = aws_route_table.public.id
  subnet_id      = each.value.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ig.id}"
}


/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "${var.environment}-igw"
    Environment = "${var.environment}"
  }
}


/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  domain                    = "vpc"
  depends_on = [aws_internet_gateway.ig]
}

/*==== VPC's Default Security Group ======*/
resource "aws_security_group" "default" {
  name        = "${var.environment}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = "${aws_vpc.vpc.id}"
  depends_on  = [aws_vpc.vpc]
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }
  
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
  tags = {
    Environment = "${var.environment}"
  }
}
 
