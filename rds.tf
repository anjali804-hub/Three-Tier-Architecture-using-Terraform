
resource "aws_db_subnet_group" "main" {

  name = "three-tier-db-subnet"

  subnet_ids = [
    aws_subnet.db_az1.id,
    aws_subnet.db_az2.id
  ]

  description = "Private subnet group for RDS"

  tags = {
    Name = "Three-Tier-DB-Subnet-Group"
  }
}

resource "aws_db_instance" "main" {

  identifier = "three-tier-mysql-db"

  engine         = "mysql"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "applicationdb"
  username = var.db_username
  password = var.db_password

  port = 3306

  db_subnet_group_name = aws_db_subnet_group.main.name

  vpc_security_group_ids = [
    aws_security_group.db_sg.id
  ]

  publicly_accessible = false

  multi_az = false

  backup_retention_period = 1

  auto_minor_version_upgrade = true

  deletion_protection = false

  skip_final_snapshot = true

  apply_immediately = true

  tags = {
    Name = "Three-Tier-MySQL-Database"
  }
}
