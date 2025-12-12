terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

resource "aws_db_subnet_group" "this" {
  name       = "rds-postgres-subnet-group"
  subnet_ids = [/* your subnet IDs here */]

  tags = {
    Name = "rds-postgres-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier              = "my-postgres-db"
  engine                  = "postgres"
  engine_version          = "16.4"        # adjust as needed
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [/* your SG IDs here */]
  skip_final_snapshot     = true
  publicly_accessible     = false
  deletion_protection     = false
  auto_minor_version_upgrade = true

  tags = {
    Name = "my-postgres-db"
    Env  = "dev"
  }
}
