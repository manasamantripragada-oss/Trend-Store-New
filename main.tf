provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "devops_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.devops_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_security_group" "jenkins_sg" {
  vpc_id = aws_vpc.devops_vpc.id
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name      = "my-key"

  user_data = <<EOF
#!/bin/bash
apt update
apt install -y openjdk-17-jdk docker.io
systemctl start docker
systemctl enable docker
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | tee \
/usr/share/keyrings/jenkins-keyring.asc > /dev/null
EOF
}
