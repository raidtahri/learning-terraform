# bootstrap include:
# Bucket
# Versioning
# Encryption
# Public access block
# Lifecycle configuration
# DynamoDB lock table
# prevent_destroy

resource "aws_s3_bucket" "tf_state" {
  bucket = "learning-terraform-state"
  # Versioning is managed with a separate resource (aws_s3_bucket_versioning)
  # The nested `versioning` block on aws_s3_bucket is deprecated.
  lifecycle {
    prevent_destroy = true #protects state bucket from accidental deletion
  }
  tags = {
    Environment         = "Bootstrap"
    InfrastructureOwner = "devops-team"
    Project             = "learning-terraform"
    ManagedBy           = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled" #enabling versioning allows us to recover previous versions of the state file in case of accidental corruption or deletion,
  }
}

# consider KMS-managed keys in the futur
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" { #Ensures that all objects in the state bucket are encrypted at rest using AES256 encryption.
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


#Prevents accidental exposure of sensitive state files
#Covers ACLs and bucket policies
#Extra safety layer
resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# This resource tells AWS:
# “For this S3 bucket, automatically delete old object versions after 90 days.”

resource "aws_s3_bucket_lifecycle_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}



resource "aws_dynamodb_table" "tf_lock" { #Prevents simultaneous terraform apply from corrupting your state
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S" #String type for the lock ID, which will be used to identify the lock in the table. we also have N for number and B for binary types
  }
  tags = {
    Environment         = "Bootstrap"
    InfrastructureOwner = "devops-team"
    Project             = "learning-terraform"
    ManagedBy           = "terraform"
  }
}


