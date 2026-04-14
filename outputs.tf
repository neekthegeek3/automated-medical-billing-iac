# The VPC ID (for troubleshooting)
output "vpc_id" {
  value = module.networking.vpc_id
}

output "private_subnet_ids" {
  value = module.networking.private_subnets
}

output "table_name" {
  value = module.storage.table_name
}

output "bucket_arn" {
  value = module.storage.bucket_arn
}

output "kms_key_arn" {
  value = module.storage.kms_key_arn
}

output "ingestion_bucket_name" {
  value = module.ingestion.email_inbox_bucket_name
}

output "ses_domain" {
  value = module.ingestion.ses_domain_identity
}

output "domain_name" {
  value = var.domain_name
}