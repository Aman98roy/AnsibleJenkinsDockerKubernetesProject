# # Terraform Settings Block
# terraform {
#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#       #version = "~> 3.21" # Optional but recommended in production
#     }
#   }
# }

# # Provider Block
# provider "aws" {
#   profile = "default" # AWS Credentials Profile configured on your local desktop terminal  $HOME/.aws/credentials
#   region  = "us-east-1"
# }

# # Resource Block
# resource "aws_instance" "ec2demo" {
#   ami           = "ami-026ebd4cfe2c043b2" # Amazon Linux in us-east-1, update as per your region
#   instance_type = "t2.micro"
#   #   key_name = "aman"
#   security_groups = ["aman-sg"]
#   subnet_id = aws_subnet.aman-public-subnet-01.id
# }


# resource "aws_security_group" "aman-sg" {
#   name        = "aman-sg"
#   description = "SSH ACcess group"
#   vpc_id = aws_vpc.aman-vpc.id

#   ingress {
#     description = "SHH ACcess group"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "ssh-access"
#   }

# }



