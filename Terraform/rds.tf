
resource "aws_db_subnet_group" "rds_private" {
  name = "name-app-private-db-subnet-group"

  subnet_ids = [
    aws_subnet.subnet_az1_private.id,
    aws_subnet.subnet_az2_private.id,
    aws_subnet.subnet_az3_private.id
  ]

  tags = {
    Name = "name-app-private-db-subnet-group"
  }
}


resource "aws_db_instance" "app_db" {
  identifier = "name-app-db-private"

  engine         = "postgres"
  engine_version = "18.3"

  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  storage_type          = "gp3"
  max_allocated_storage = 100

  db_name  = "nameapp"
  username = "postgres"
  password = var.db_password

  port = 5432

  db_subnet_group_name = aws_db_subnet_group.rds_private.name

  vpc_security_group_ids = [
    aws_security_group.rds_sg.id
  ]

  publicly_accessible = false

  multi_az = false

  backup_retention_period = 1

  skip_final_snapshot = true
  deletion_protection = false

  apply_immediately = true

  tags = {
    Name = "name-app-db-private"
  }
}


resource "aws_secretsmanager_secret" "rds" {
  name = "name-app/rds"

  tags = {
    Name = "name-app-rds-secret"
  }
}


resource "aws_secretsmanager_secret_version" "rds" {
  secret_id = aws_secretsmanager_secret.rds.id

  secret_string = jsonencode({
    DB_HOST     = aws_db_instance.app_db.address
    DB_NAME     = "nameapp"
    DB_USER     = "postgres"
    DB_PASSWORD = var.db_password
    DB_PORT     = "5432"
  })
}
