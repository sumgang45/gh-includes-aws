resource "aws_vpc" "ase-ecr-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ase-ecr-${random_string.suffix.result}"
  }
}
