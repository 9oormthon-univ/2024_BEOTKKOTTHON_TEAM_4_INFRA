
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
    from_port = 1194
    to_port = 1194
    protocol = "udp"
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
  ami           = "ami-0d129a865e42570cc"
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
