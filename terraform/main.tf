provider "aws" {
  region     = "ap-southeast-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_key_pair" "monitoring" {
  key_name   = "monitoring-key"
  public_key = file("/home/ec2-user/.ssh/monitoring_key.pub")
}

resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring-sg"
  description = "Allow SSH, Prometheus, Grafana"

  ingress {
    from_port   = 22
    to_port     = 22
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
    from_port   = 3000
    to_port     = 3000
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

resource "aws_instance" "rhel_monitor" {
  ami                    = "ami-0705fe1e9a50e0d57" # RHEL 9 in us-east-1
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.monitoring.key_name
  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]

  tags = {
    Name = "monitoring-rhel"
  }
}

