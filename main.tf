# Configure the AWS provider
provider "aws" {
  region = "ca-central-1"
  access_key              = var.AWS_ACCESS_KEY_ID
  secret_key              = var.AWS_SECRET_ACCESS_KEY
}

# Reference existing public and private subnets instead of creating them
data "aws_subnet" "public_subnet_1" {
  filter {
    name   = "cidrBlock"
    values = [var.public_subnet_cidrs[0]]
  }
  vpc_id = var.vpc_id
}

data "aws_subnet" "public_subnet_2" {
  filter {
    name   = "cidrBlock"
    values = [var.public_subnet_cidrs[1]]
  }
  vpc_id = var.vpc_id
}

data "aws_subnet" "private_subnet_1" {
  filter {
    name   = "cidrBlock"
    values = [var.private_subnet_cidrs[0]]
  }
  vpc_id = var.vpc_id
}

data "aws_subnet" "private_subnet_2" {
  filter {
    name   = "cidrBlock"
    values = [var.private_subnet_cidrs[1]]
  }
  vpc_id = var.vpc_id
}

# Public route table configuration
resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  tags = {
    Name = "tfd-pub-rt"
  }
}

# Private route table configuration (no internet access)
resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id

  tags = {
    Name = "tfd-priv-rt"
  }
}

# Associate existing private subnets with private route table
resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = data.aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = data.aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

# Associate existing public subnets with the public route table
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = data.aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = data.aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Reference existing security group instead of creating a new one
data "aws_security_group" "web_sg" {
  id = var.security_group_id
}

# Launch EC2 instance in public subnet
resource "aws_instance" "web_server" {
  ami                    = "ami-0208b77a23d891325"
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [data.aws_security_group.web_sg.id]
  associate_public_ip_address = true
  key_name               = var.key_pair_name

  # User data script for the web server
  user_data = <<-EOF
    #!/bin/bash
    sudo yum install -y busybox
    echo "<h1>Welcome to tfd'82</h1>" > index.html
    nohup busybox httpd -f -p 8080 &
  EOF

  tags = {
    Name = "servera"
  }
}
