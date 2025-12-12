#####################################
# Provider
#####################################
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

#####################################
# Networking (VPC + Subnets)
#####################################
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "rds-vpc"
  }
}

# Private subnet in us-east-1a
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "rds-private-a"
  }
}

# Private subnet in us-east-1b
resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "rds-private-b"
  }
}

#####################################
# RDS Subnet Group
#####################################
resource "aws_db_subnet_group" "rds" {
  name       = "rds-postgres-subnet-group"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
  ]

  tags = {
    Name = "rds-postgres-subnet-group"
  }
}

#####################################
# Security Group for RDS
#####################################
resource "aws_security_group" "rds" {
  name        = "rds-postgres-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = aws_vpc.main.id

  # Example: allow Postgres from within the VPC
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-postgres-sg"
  }
}

#####################################
# RDS PostgreSQL Instance
#####################################
resource "aws_db_instance" "postgres" {
  identifier                 = "my-postgres-db"
  engine                     = "postgres"
  engine_version             = "16.3"
  instance_class             = "db.t3.micro"
  allocated_storage          = 20
  username                = "maloke"
  password                = "admin123"
  db_subnet_group_name       = aws_db_subnet_group.rds.name  # 👈 use newly created subnet group
  vpc_security_group_ids     = [aws_security_group.rds.id]
  skip_final_snapshot        = true
  publicly_accessible        = false
  deletion_protection        = false
  auto_minor_version_upgrade = true

  tags = {
    Name = "my-postgres-db"
    Env  = "dev"
  }
}

#####################################
# Outputs (optional)
#####################################
output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}

output "rds_port" {
  value = aws_db_instance.postgres.port
}


