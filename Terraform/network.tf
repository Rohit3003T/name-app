resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/20"
  instance_tenancy = "default"

  tags = {
    Name = "aws_infra_vpc"
  }
}
# subnet
resource "aws_subnet" "subnet_az1_public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "aws_infra_subnet_az1_public"
  }
}
resource "aws_subnet" "subnet_az2_public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "aws_infra_subnet_az2_public"
  }

}

resource "aws_subnet" "subnet_az3_public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-south-1c"
  tags = {
    Name = "aws_infra_subnet_az3_public"
  }

}

resource "aws_subnet" "subnet_az1_private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "aws_infra_subnet_az1_private"
  }
}
resource "aws_subnet" "subnet_az2_private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "aws_infra_subnet_az2_private"
  }

}

resource "aws_subnet" "subnet_az3_private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.13.0/24"
  availability_zone = "ap-south-1c"
  tags = {
    Name = "aws_infra_subnet_az3_private"
  }

}
# ig
resource "aws_internet_gateway" "aws_internet_gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "aws_internet_gateway"
  }


}
# pb rout
resource "aws_route_table" "route_public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_internet_gateway.id
  }
  tags = {
    Name = "route_public"
  }

}

resource "aws_route_table_association" "r_as_pb_az1" {
  subnet_id      = aws_subnet.subnet_az1_public.id
  route_table_id = aws_route_table.route_public.id

}
resource "aws_route_table_association" "r_as_pb_az2" {
  subnet_id      = aws_subnet.subnet_az2_public.id
  route_table_id = aws_route_table.route_public.id

}
resource "aws_route_table_association" "r_as_pb_az3" {
  subnet_id      = aws_subnet.subnet_az3_public.id
  route_table_id = aws_route_table.route_public.id

}
# pv rout
resource "aws_route_table" "route_private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "route_private"
  }

}

resource "aws_route_table_association" "r_as_pvt_az1" {
  subnet_id      = aws_subnet.subnet_az1_private.id
  route_table_id = aws_route_table.route_private.id

}
resource "aws_route_table_association" "r_as_pvt_az2" {
  subnet_id      = aws_subnet.subnet_az2_private.id
  route_table_id = aws_route_table.route_private.id

}
resource "aws_route_table_association" "r_as_pvt_az3" {
  subnet_id      = aws_subnet.subnet_az3_private.id
  route_table_id = aws_route_table.route_private.id

}
# nat
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "nat_eip"
  }
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet_az1_public.id

  tags = {
    Name = "nat_gateway"
  }

  depends_on = [
    aws_internet_gateway.aws_internet_gateway
  ]
}
resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.route_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}