terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  access_key = "test"
  secret_key = "test"
  region     = "us-east-1"

  # LocalStack endpoint configuration
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3  = "http://localhost:4566"
    ec2 = "http://localhost:4566"
  }
}

resource "aws_instance" "db" {
  ami             = "ami-12345678"
  instance_type   = var.instance_type
  security_groups = [aws_security_group.web.name] # On peut réutiliser le même SG pour l'instant
  key_name        = aws_key_pair.deployer.key_name

  tags = {
    Name = "var.db_instance_name"
  }
}