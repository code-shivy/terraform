# Configuring AWS provider
provider "aws" {
  region = var.region # Replace with your desired region
  access_key =   var.access_key ## Retriving acesskey from AWS_secrets manager
  secret_access_key = var.secret_access_key
}


# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
}

# Create internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_cidr_block
  availability_zone = var.az 
}

# Create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_cidr_block
  availability_zone = var.az 
}

# Create NAT gateway in the public subnet
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
}

# Allocate Elastic IP for NAT gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}



# Provision EC2 instance for Jenkins with user data
resource "aws_instance" "jenkins_instance" {
  ami                    = data.ami.ubuntu.id 
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              # Install Jenkins
              sudo apt update
              sudo apt install -y openjdk-8-jdk
              wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add -
              sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
              sudo apt update
              sudo apt install -y jenkins

              # Install Ansible
              sudo apt-add-repository --yes --update ppa:ansible/ansible
              sudo apt install -y ansible
              EOF

  tags = {
    Name = "Jenkins-Ansible Instance"
  }
}

# Output the public IP of Jenkins instance
output "jenkins_public_ip" {
  value = aws_instance.jenkins_instance.public_ip
}
