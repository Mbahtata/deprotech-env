
provider "aws" {
  region = "us-east-1"
}

variable "db_username" {
  type      = string
  sensitive = true
  default = "maloke"
}

variable "db_password" {
  type      = string
  sensitive = true
  default = "admin123"
}

db_username = "maloke"

db_password = "admin123"

resource "aws_db_subnet_group" "this" {
  name       = "rds-postgres-subnet-group"
  subnet_ids = ["subnet-123", "subnet-456"]  # update

  tags = {
    Name = "rds-postgres-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier              = "my-postgres-db"
  engine                  = "postgres"
  engine_version          = "16.4"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  username                = var.db_usernam
  password                = var.db_password
  vpc_security_group_ids  = ["sg-123456789"]  # update
  db_subnet_group_name    = aws_db_subnet_group.this.name
  skip_final_snapshot     = true
  publicly_accessible     = false
  deletion_protection     = false
  auto_minor_version_upgrade = true

  tags = {
    Name = "my-postgres-db"
    Env  = "dev"
  }
}

