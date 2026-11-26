
# Public Subnet - AZ 1

resource "aws_subnet" "public_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = local.az1
  map_public_ip_on_launch = true

  tags = {
    Name = "Web-Public-Subnet-AZ1"
  }
}

# Public Subnet - AZ 2

resource "aws_subnet" "public_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = local.az2
  map_public_ip_on_launch = true

  tags = {
    Name = "Web-Public-Subnet-AZ2"
  }
}

# Application Private Subnet - AZ 1

resource "aws_subnet" "app_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = local.az1

  tags = {
    Name = "App-Private-Subnet-AZ1"
  }
}

# Application Private Subnet - AZ 2

resource "aws_subnet" "app_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = local.az2

  tags = {
    Name = "App-Private-Subnet-AZ2"
  }
}

# Database Private Subnet - AZ 1

resource "aws_subnet" "db_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = local.az1

  tags = {
    Name = "DB-Private-Subnet-AZ1"
  }
}

# Database Private Subnet - AZ 2

resource "aws_subnet" "db_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = local.az2

  tags = {
    Name = "DB-Private-Subnet-AZ2"
  }
}
