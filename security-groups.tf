# Get AWS-managed EC2 Instance Connect prefix list
data "aws_ec2_managed_prefix_list" "ec2_instance_connect" {
  name = "com.amazonaws.us-east-1.ec2-instance-connect"
}

# 1. Web ALB Security Group

resource "aws_security_group" "web_alb_sg" {
  name        = "web-alb-sg"
  description = "Security group for public web ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-ALB-SG"
  }
}

# 2. Web EC2 Security Group

resource "aws_security_group" "web_ec2_sg" {
  name        = "web-ec2-sg"
  description = "Security group for web EC2 instances"
  vpc_id      = aws_vpc.main.id

  # HTTP from Web ALB
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_alb_sg.id]
  }

  # SSH from EC2 Instance Connect
  ingress {
    description     = "SSH from EC2 Instance Connect"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.ec2_instance_connect.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-EC2-SG"
  }
}

# 3. Internal ALB Security Group

resource "aws_security_group" "internal_alb_sg" {
  name        = "internal-alb-sg"
  description = "Security group for internal ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Internal-ALB-SG"
  }
}

# 4. Application EC2 Security Group

resource "aws_security_group" "app_ec2_sg" {
  name        = "app-ec2-sg"
  description = "Security group for application EC2 instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "App-EC2-SG"
  }
}

# 5. Database Security Group

resource "aws_security_group" "db_sg" {
  name        = "database-sg"
  description = "Security group for RDS MySQL"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_ec2_sg.id]
  }

  tags = {
    Name = "Database-SG"
  }
}