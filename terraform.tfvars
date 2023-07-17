data "aws_secretsmanager_secret_version" "my_secret" {
  secret_id = "my-aws-credentials-secret-id"
}

## Region in which all resources are created
variable access_key{
    default = "${aws_secretsmanager_secret_version.my_secret.secret_string}" 
}

variable secret_access_key{
    default = "${aws_secretsmanager_secret_version.my_secret.secret_string}"
}



variable region{
    default = "us-east-2"
}

## VPC CIDR block
variable vpc_cidr_block{
    default = "172.20.0.0/16"
}

##VPC public subnet cidr block
variable public_cidr_block{
    default= "172.20.10.0/24"
}

##VPC private subnet cidr block
variable private_cidr_block{
    default="172.20.20.0/24"
}

## Availability zone for public and private subnet
variable az {
    default="us-east-2a"
}

variable instance_type{
    default="t3.medium"
}


## AWS AMI data source
data "aws_ami" "ubuntu"{
    most_recent = true
    owners = ["self"]
    executable_users = ["self"]

    filter {
    name   = "name"
    values = ["myami-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}  

