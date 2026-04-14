# S3 Input Bucket
resource "aws_s3_bucket" "medical_docs" {
  bucket = "${var.project_name}-data-vault"
  tags   = merge(var.tags, {
	Name   = "${var.project_name}-S3-Inbox"
	Tier   = "Storage"
  })
}

# DynamoDB Table for Structured Results
resource "aws_dynamodb_table" "medical_entities" {
  name         = "${var.project_name}-entities"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "DocumentId"

  attribute {
    name       = "DocumentId"
    type       = "S"
  }
  
  tags         = merge(var.tags, {
	Name         = "${var.project_name}-Entities-Database"
	Tier         = "Database"
  })
}

# Add this to modules/storage/main.tf
resource "aws_kms_key" "main" {
  description             = "KMS key for Altan ACAI data encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-key"
  target_key_id = aws_kms_key.main.key_id
}