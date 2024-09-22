terraform {
  backend "s3" {
    bucket         = "tfd-terraform-state-s3"    # The name of the S3 bucket where the state will be stored
    key            = "global/s3/terraform.tfstate" # The path in the bucket to store the state file
    region         = "ca-central-1"                 # The region where the S3 bucket is located
    dynamodb_table = "terraform-state-locks"     # DynamoDB table for locking
    encrypt        = true                        # Encrypt the state file
  }
}

provider "aws" {
  region = "ca-central-1"
}

# Create S3 Bucket
resource "aws_s3_bucket" "terraform_state" {
    bucket = "tfd-terraform-state-s3"
    acl    = "private"  # Access control list (ACL) for bucket

    # Prevent accidental deletion of this S3 bucket
    lifecycle {
        prevent_destroy = true
    }

    tags = {
        Name = "tfd-s3-bucket"
    }
}

# Enable versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "enabled" {
    bucket = aws_s3_bucket.terraform_state.id

    versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
    bucket = aws_s3_bucket.terraform_state.id

    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256" # Specifies the encryption algorithm (AES256)
      }
    }
}

# Block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "block_public_access" {
    bucket                  = aws_s3_bucket.terraform_state.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

# Create a dynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
    name    = "terraform-state-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }

    tags = {
        Name = "Terraform Lock Table"
    }
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}