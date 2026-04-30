terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

resource "aws_security_group" "mon_sg" {
  name = "mon-pipeline-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "ma_cle" {
  key_name   = "mon-pipeline-key"
  public_key = file("mon-pipeline-key.pub")
}

resource "aws_instance" "mon_serveur" {
  ami           = "ami-045a8ab02aadf4f88"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.mon_sg.id]
  key_name = aws_key_pair.ma_cle.key_name
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io
    systemctl start docker
  EOF
  tags = {
    Name = "mon-pipeline-server"
  }
}

output "ip_publique" {
  value = aws_instance.mon_serveur.public_ip
}