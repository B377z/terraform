# Define variables for common values
variable "vpc_id" {
    description = "Default VPC ID tfd-default"
    default     = "vpc-06fd63ceb391a236d"
}

variable "availability_zone" {
    description = "List of availability zones"
    default     = ["ca-central-1a", "ca-central-1b"]
}

variable "public_subnet_cidrs" {
    description = "List of CIDR blocks for public subnets"
    default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  default     = "igw-00e5c0a677918ad8e"
}

variable "security_group_id" {
  description = "The ID of the security group"
  default     = "sg-0e3ff8f5108fcb7ae"
}

variable "key_pair_name" {
  description = "The name of the SSH key pair"
  default     = "terraformkeypair1909"
}

variable "server_port" {
  description = "The port on which the web servers will listen"
  default     = 8080
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "The secret access key for AWS"
  type        = string
  sensitive   = true  # Mark this as sensitive to avoid logging it
}

