terraform {
  backend "s3" {
    bucket         = "learning-terraform-state"
    key            = "dev/eu-north-1/terraform.tfstate"#it is path inside bucket where state file will be stored. prod/eu-north-1/terraform.tfstate, dev/us-east-1/terraform.tfstate, etc
    region         = "eu-north-1"#Must match the region where: S3 bucket exists , DynamoDB table exists in bootstrap main.tf, Backend cannot cross regions.
    dynamodb_table = "terraform-lock"#DynamoDB table for state locking to prevent concurrent modifications
    encrypt        = true
  }
}
