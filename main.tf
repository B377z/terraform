# Configure the AWS provider
provider "aws" {
  region = "ca-central-1"  # Set the AWS region (central)
}

# Create 2 more public subnets in the VPC
resource "aws_subnet" "public_subnet_1" {
  vpc_id        = var.vpc_id
  cidr_block    = var.public_subnet_cidrs[0]
  availability_zone = var.availability_zone[0]

  tags = {
    Name = "publicSubnet1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id        = var.vpc_id
  cidr_block    = var.public_subnet_cidrs[1]
  availability_zone = var.availability_zone[1]

  tags = {
    Name = "publicSubnet2"
  }
}

# Create 2 private subnets in the VPC
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_cidrs[0]  # Use the first private CIDR block
  availability_zone = var.availability_zone[0]

  tags = {
    Name = "privateSubnet1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_cidrs[1]  # Use the second private CIDR block
  availability_zone = var.availability_zone[1]

  tags = {
    Name = "privateSubnet2"
  }
}

# Create public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id

  # Route all traffic to Internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id  # Use the variable for the Internet Gateway ID
  }

  tags = {
    Name = "tfd-pub-rt"
  }
}

# Create a custom route table for private subnets (no internet access)
resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id

  tags = {
    Name = "tfd-priv-rt"
  }
}

# Associate the private subnets with the custom route table
resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

# Associate the public subnets with the public route table
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow traffic on the web server port"
    from_port   = var.server_port
    to_port     = var.server_port
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
    Name = "web-sg"
  }
}

resource "aws_instance" "web_server" {
  ami                    = "ami-0208b77a23d891325"  # You can also make this an input variable if needed
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [var.security_group_id]
  associate_public_ip_address = true
  key_name               = var.key_pair_name

  # User data script for the web server
  user_data = <<-EOF
    #!/bin/bash
    # Install BusyBox
    sudo yum install -y busybox
    echo "<h1>Welcome to tfd'82</h1>" > index.html
    nohup busybox httpd -f -p 8080 &
  EOF

  tags = {
    Name = "servera"
  }
}
