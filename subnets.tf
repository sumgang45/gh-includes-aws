resource "aws_subnet" "public-subnet1" {
  cidr_block              = var.public_subnet_cidr1
  vpc_id                  = aws_vpc.ase-ecr-vpc.id
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ase-ecr-Public-Subnet1-${random_string.suffix.result}"
  }
}

resource "aws_subnet" "public-subnet2" {
  cidr_block              = var.public_subnet_cidr2
  vpc_id                  = aws_vpc.ase-ecr-vpc.id
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "ase-ecr-Public-Subnet2-${random_string.suffix.result}"
  }
}

resource "aws_route_table_association" "public-subnet1" {
  route_table_id = aws_route_table.public-route.id
  subnet_id      = aws_subnet.public-subnet1.id
}

resource "aws_route_table_association" "public-subnet2" {
  route_table_id = aws_route_table.public-route.id
  subnet_id      = aws_subnet.public-subnet2.id
}
