# Fetch information about the existing VPC
data "aws_vpc" "existing_vpc" {
  id = "vpc-06fd63ceb391a236d"  # Replace with your existing VPC ID
}


resource "aws_subnet" "public_subnet_1" {
  vpc_id            = data.aws_vpc.existing_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ca-central-1a"

  tags = {
    Name = "publicSubnet1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = data.aws_vpc.existing_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ca-central-1b"

  tags = {
    Name = "publicSubnet2"
  }
}

# Create private subnets in the existing VPC
resource "aws_subnet" "private_subnet_1" {
  vpc_id        = data.aws_vpc.existing_vpc.id
  cidr_block    = "10.0.3.0/24"
  availability_zone = "ca-central-1a"

  tags = {
    Name = "privateSubnet1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id        = data.aws_vpc.existing_vpc.id
  cidr_block    = "10.0.4.0/24"
  availability_zone = "ca-central-1b"

  tags = {
    Name = "privateSubnet2"
  }
}

# Create public route table in the existing VPC
resource "aws_route_table" "public_route_table" {
  vpc_id = data.aws_vpc.existing_vpc.id

  # Route all traffic to Internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-00e5c0a677918ad8e"  # Ensure this is correct for your setup
  }

  tags = {
    Name = "tfd-pub-rt"
  }
}

# Create private route table in the existing VPC
resource "aws_route_table" "private_route_table" {
  vpc_id = data.aws_vpc.existing_vpc.id

  tags = {
    Name = "tfd-priv-rt"
  }
}

# Associate subnets with route tables as needed
resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "web_server_sg" {
  vpc_id = data.aws_vpc.existing_vpc.id

  ingress {
    from_port   = var.web_server_port
    to_port     = var.web_server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server-sg"
  }
}
