
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.ase-ecr-vpc.id
  tags = {
    Name = "ase-ecr-Gateway-${random_string.suffix.result}"
  }
}
resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.ase-ecr-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
  tags = {
    Name = "Public Subnet Route"
  }
}