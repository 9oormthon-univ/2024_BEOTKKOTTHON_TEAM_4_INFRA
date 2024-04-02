terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.7.0"

  name = "vacgom-vpc-2"
  cidr = "10.0.0.0/16"

  azs = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]


  enable_nat_gateway = false
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}


resource "aws_security_group" "nat-instance-sg" {
  name = "nat-instance-sg"
  description = "Security Group for Nat Instance"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"

    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_network_interface" "nat-nic" {
  subnet_id = module.vpc.public_subnets[0]
  private_ip = "10.0.101.1"


  security_groups = [aws_security_group.nat-instance-sg.id]

  source_dest_check = false
}

resource "aws_eip" "nat-instance-eip" {
  instance = aws_instance.nat-instance.id
  domain = "vpc"
}

resource "aws_instance" "nat-instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"


  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.nat-nic.id
  }

  key_name = "vacgom"

  tags = {
    Name = "VacgomNatInstance"
  }
}


resource "aws_route" "nat-instance-route" {
  count = 2

  depends_on = [aws_instance.nat-instance, module.vpc]
  route_table_id = module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id = aws_network_interface.nat-nic.id
}
