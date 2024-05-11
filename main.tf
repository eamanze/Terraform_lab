locals {
  Name = "emeka"
}

# creating vpc
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
  tags = {
    Name = "${local.Name}-vpc"
  }
}
// creating public subnet
resource "aws_subnet" "pub1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr2
  availability_zone = "eu-west-1a"
  tags = {
    Name = "${local.Name}-subnet"
  }
}
// creating internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${local.Name}-igw"
  }
}
// creating route table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.all-cidr
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${local.Name}-rt"
  }
}
// creating route table association for public subnet
resource "aws_route_table_association" "ass-pub" {
  subnet_id      = aws_subnet.pub1.id
  route_table_id = aws_route_table.rt.id
}
// creating security group
resource "aws_security_group" "sg" {
  name        = "${local.Name}-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${local.Name}-sg"
  }
}
resource "aws_security_group_rule" "rule1" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.all-cidr]
  security_group_id = aws_security_group.sg.id
}
resource "aws_security_group_rule" "rule2" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.all-cidr]
  security_group_id = aws_security_group.sg.id
}
// creating keypair
resource "aws_key_pair" "key" {
  key_name   = "${local.Name}-key"
  public_key = file("./emeka-key.pub")
}
// creating instance
resource "aws_instance" "instance" {
  ami                         = "ami-08e592fbb0f535224" //red-hat
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.pub1.id
  associate_public_ip_address = true
  tags = {
    Name = "${local.Name}-instance"
  }
}