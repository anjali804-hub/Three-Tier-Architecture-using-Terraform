
resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table" "app_rt_az1" {

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_az1.id
  }

  tags = {
    Name = "App-Private-RT-AZ1"
  }
}

resource "aws_route_table" "app_rt_az2" {

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_az2.id
  }

  tags = {
    Name = "App-Private-RT-AZ2"
  }
}


resource "aws_route_table" "db_rt" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "DB-Private-Route-Table"
  }
}

# Public subnet associations

resource "aws_route_table_association" "public_assoc_az1" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_az2" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public_rt.id
}

# Application subnet associations

resource "aws_route_table_association" "app_assoc_az1" {
  subnet_id      = aws_subnet.app_az1.id
  route_table_id = aws_route_table.app_rt_az1.id
}

resource "aws_route_table_association" "app_assoc_az2" {
  subnet_id      = aws_subnet.app_az2.id
  route_table_id = aws_route_table.app_rt_az2.id
}

# Database subnet associations

resource "aws_route_table_association" "db_assoc_az1" {
  subnet_id      = aws_subnet.db_az1.id
  route_table_id = aws_route_table.db_rt.id
}

resource "aws_route_table_association" "db_assoc_az2" {
  subnet_id      = aws_subnet.db_az2.id
  route_table_id = aws_route_table.db_rt.id
}

