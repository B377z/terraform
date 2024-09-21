variable "instance_type" {
  description = "The type of instance to use for the Auto Scaling Group"
  type        = string
  default     = "t2.micro"  # Default instance type
}

variable "ami_servera" {
    description = "AMI ID for servera"
    type        = string
    default     = "ami-0208b77a23d891325"  # Default AMI ID for servera
}

variable "ami_serverb" {
    description = "AMI ID for serverb"
    type        = string
    default     = "ami-0c6d358ee9e264ff1"
}

variable "key_name" {
    description = "Key pair name for SSH access"
    type        = string
    default     = "terraformkeypair1909"
}

variable "web_server_port" {
    description = "Port number for the web server"
    type        = number
    default     = 8080  # Default to 8080 but can be overridden
}

variable "subnet_public_1" {
  description = "Subnet ID for public subnet 1"
  type        = string

  validation {
    condition     = length(var.subnet_public_1) > 0
    error_message = "A valid subnet ID for public subnet 1 must be provided."
  }
}

variable "subnet_public_2" {
  description = "Subnet ID for public subnet 2"
  type        = string

  validation {
    condition     = length(var.subnet_public_2) > 0
    error_message = "A valid subnet ID for public subnet 2 must be provided."
  }
}

variable "security_group_servera" {
  description = "Security group for server A"
  type        = string
  default     = "sg-0e3ff8f5108fcb7ae"
}

variable "security_group_serverb" {
  description = "Security group for server B"
  type        = string
  default     = "sg-04dfbb558975ea17f"
}