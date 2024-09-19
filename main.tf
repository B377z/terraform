# Configure the AWS provider
provider "aws" {
  region = "ca-central-1"  # Set the AWS region (central)
}

# Create 2 more public subnets in the VPC
resource "aws_subnet" "public_subnet_1" {
  vpc_id        = "vpc-06fd63ceb391a236d"
  cidr_block    = "10.0.1.0/24"
  availability_zone = "ca-central-1a"

  tags = {
    Name = "publicSubnet1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id        = "vpc-06fd63ceb391a236d"
  cidr_block    = "10.0.2.0/24"
  availability_zone = "ca-central-1b"

  tags = {                                                                                         Name = "publicSubnet2"
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id        = "vpc-06fd63ceb391a236d"
  cidr_block    = "10.0.3.0/24"
  availability_zone = "ca-central-1d"

  tags = {                                                                                         Name = "publicSubnet3"
  }     
}


resource "aws_subnet" "private_subnet_1" {
  vpc_id        = "vpc-06fd63ceb391a236d"
  cidr_block    = "10.0.4.0/24"
  availability_zone = "ca-central-1a"

  tags = {
    Name = "privateSubnet1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id        = "vpc-06fd63ceb391a236d"
  cidr_block    = "10.0.5.0/24"
  availability_zone = "ca-central-1b"

  tags = {                                                                                         Name = "privateSubnet2"
  }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id        = "vpc-06fd63ceb391a236d"
  cidr_block    = "10.0.6.0/24"
  availability_zone = "ca-central-1d"

  tags = {                                                                                         Name = "privateSubnet3"
  }
}

# Create public route table
resource "aws_route_table" "public_route_table" {
  vpc_id        = "vpc-06fd63ceb391a236d"

  # Route all traffic to Internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-00e5c0a677918ad8e"
  }

  tags = {
    Name = "tfd-pub-rt"
  }
}

# Create a custom route table for private subnets (no internet access)
resource "aws_route_table" "private_route_table" {
  vpc_id = "vpc-06fd63ceb391a236d"  # Use your VPC ID

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

resource "aws_route_table_association" "private_subnet_3_association" {
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.private_route_table.id
}

# Associate the public subnets with the custom route table
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_3_association" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.public_route_table.id
}
    
resource "aws_instance" "web_server" {
  ami           = "ami-0208b77a23d891325"  # Replace with a valid AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_1.id  # Use your public subnet

  # Associate the instance with an existing security group using the security group ID
  vpc_security_group_ids = ["sg-0e3ff8f5108fcb7ae"]  # Replace with your Security Group ID

  # Ensure the instance gets a public IP
  associate_public_ip_address = true

  # Use the key pair name for SSH access
  key_name = "terraformkeypair1909"  # Name of the key pair in AWS

  # Add the user data script to install httpd and create an HTML file
  user_data = <<-EOF
    #!/bin/bash
    # Update the package repository
    yum update -y

    # Install Apache HTTPD
    yum install -y httpd

    # Start the HTTPD service
    systemctl start httpd
    systemctl enable httpd

    # Create the index.html file with the custom message
    echo "Welcome to tfd'82" > /var/www/html/index.html

    # Ensure proper permissions
    chown apache:apache /var/www/html/index.html
    chmod 644 /var/www/html/index.html
  EOF

  tags = {
    Name = "servera"
  }
}

