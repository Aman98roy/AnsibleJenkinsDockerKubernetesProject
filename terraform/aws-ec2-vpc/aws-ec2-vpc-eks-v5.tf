# Terraform Settings Block
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = "~> 3.21" # Optional but recommended in production
    }
  }
}

# Provider Block
provider "aws" {
  profile = "default" # AWS Credentials Profile configured on your local desktop terminal  $HOME/.aws/credentials
  region  = "us-east-1"
}

# Resource Block
resource "aws_instance" "ec2demo" {
  ami           = "ami-053b0d53c279acc90" # Amazon Linux in us-east-1, update as per your region
  instance_type = "t2.micro"
  key_name      = "aman"
  # security_groups = ["aman-sg"]
  vpc_security_group_ids = [aws_security_group.aman-sg.id]
  subnet_id              = aws_subnet.aman-public-subnet-01.id
  for_each               = toset(["Jenkins-Master", "Build-Slave", "Ansible"])
  tags = {
    Name = "${each.key}"
  }
}


resource "aws_security_group" "aman-sg" {
  name        = "aman-sg"
  description = "SSH ACcess group"
  vpc_id      = aws_vpc.aman-vpc.id

  ingress {
    description = "SHH ACcess group"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Jenkins Port"
    from_port   = 8080
    to_port     = 8080
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
    Name = "ssh-access"
  }

}

resource "aws_vpc" "aman-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "aman-vpc"
  }

}

resource "aws_subnet" "aman-public-subnet-01" {
  vpc_id                  = aws_vpc.aman-vpc.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"
  tags = {
    Name = "aman-public-subnet-01"
  }

}

resource "aws_subnet" "aman-public-subnet-02" {
  vpc_id                  = aws_vpc.aman-vpc.id
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1b"
  tags = {
    Name = "aman-public-subnet-02"
  }

}

resource "aws_internet_gateway" "aman-igw" {
  vpc_id = aws_vpc.aman-vpc.id
  tags = {
    Name : "aman-igw"
  }

}

resource "aws_route_table" "aman-public-rt" {
  vpc_id = aws_vpc.aman-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aman-igw.id
  }

}

resource "aws_route_table_association" "aman-rta-public-subnet-01" {
  subnet_id      = aws_subnet.aman-public-subnet-01.id
  route_table_id = aws_route_table.aman-public-rt.id

}

resource "aws_route_table_association" "aman-rta-public-subnet-02" {
  subnet_id      = aws_subnet.aman-public-subnet-02.id
  route_table_id = aws_route_table.aman-public-rt.id

}

module "sgs" {
  source = "../eks-sg"
  vpc_id = aws_vpc.aman-vpc.id
}

module "eks" {
  source     = "../eks"
  vpc_id     = aws_vpc.aman-vpc.id
  subnet_ids = [aws_subnet.aman-public-subnet-01.id, aws_subnet.aman-public-subnet-02.id]
  sg_ids     = module.sgs.security_group_public
}

