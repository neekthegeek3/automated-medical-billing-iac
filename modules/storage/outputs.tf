output "bucket_name" {
  value = aws_s3_bucket.medical_docs.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.medical_docs.arn
}

# This provides the "bucket_id" the ingestion module is looking for
output "bucket_id" {
  value       = aws_s3_bucket.medical_docs.id
  description = "The ID of the main processing bucket"
}

output "table_name" {
  value = aws_dynamodb_table.medical_entities.name
}

output "table_arn" {
  value = aws_dynamodb_table.medical_entities.arn
}

output "kms_key_arn" {
  value       = aws_kms_key.main.arn 
  description = "The ARN of the KMS key for encryption"
}