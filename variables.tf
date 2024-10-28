# Define variables for common values
variable "vpc_id" {
  description = "The VPC ID for the resources"
  default     = "vpc-06fd63ceb391a236d"
}

variable "availability_zone" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ca-central-1a", "ca-central-1b"]
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "internet_gateway_id" {
  description = "The ID of the Internet Gateway for the VPC"
  default     = "igw-00e5c0a677918ad8e"
}

variable "security_group_id" {
  description = "The ID of the existing security group to be used for the EC2 instance"
  default     = "sg-0e3ff8f5108fcb7ae"
}

variable "key_pair_name" {
  description = "The name of the SSH key pair for EC2 access"
  default     = "terraformkeypair1909"
}

variable "server_port" {
  description = "The port on which the web server will listen"
  default     = 8080
}

# Remove sensitive AWS credentials from variables.tf if using environment variables
