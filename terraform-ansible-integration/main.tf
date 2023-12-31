locals {
    vpc_id = "vpc-e8ea1483"                                            ## Replace with your VPCID
    subnet_id = "subnet-0f2ce71c3a50455c6"                             ## Replace with your SubnetID
    ssh_user = "ubuntu"
    key_name = "devops"                                                ## Replace with your Key name
    private_key_path = "/Users/shubhamsingh/Downloads/devops.pem"      ## Replace with your Private Key Path    
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_security_group" "nginx" {
  name   = "nginx_access"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "nginx" {
  ami                         = "ami-0835852ec6b67abba"                ## Replace with your AMI
  subnet_id                   = "subnet-0f2ce71c3a50455c6"             ## Replace with your Subnet
  instance_type               = "t2.micro"                             ## Replace with your Instance Type
  associate_public_ip_address = true
  security_groups             = [aws_security_group.nginx.id]
  key_name                    = local.key_name

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.nginx.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.nginx.public_ip}, --private-key ${local.private_key_path} nginx.yaml"
  }
}

output "nginx_ip" {
  value = aws_instance.nginx.public_ip
}
