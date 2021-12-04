terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.68.0"
    }
  }
  backend "s3" {
    bucket = "apatapniou-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_subnet" "main_subnet" {
  availability_zone       = "us-east-1a"
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_launch_template" "lt_first" {
  name          = "first_instance"
  image_id      = data.aws_ssm_parameter.webserver_ami.value
  instance_type = "t2.micro"
  network_interfaces {
    subnet_id       = aws_subnet.main_subnet.id
    security_groups = [aws_security_group.allow_tls.id]
  }
  placement {
    availability_zone = "us-east-1a"
  }
  user_data = filebase64("${path.module}/scripts/install-nginx.sh")
  key_name  = aws_key_pair.deployer.id
  tags = {
    Name = "nginx"
  }
}

data "aws_ssm_parameter" "webserver_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn-ami-hvm-x86_64-ebs"
}

resource "aws_autoscaling_group" "asg_first" {
  name               = "first_asg"
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.lt_first.id
    version = "$Latest"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id
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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_tls"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("/opt/keys/id_rsa.pub")
}