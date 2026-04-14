output "email_inbox_bucket_name" {
  value = aws_s3_bucket.email_inbox.bucket
  description = "The name of the S3 bucket where raw emails are stored."
}

output "email_inbox_bucket_arn" {
  value       = aws_s3_bucket.email_inbox.arn
  description = "The ARN of the S3 bucket (used for IAM policy scoping)."
}

output "ses_domain_identity" {
  value = aws_ses_domain_identity.main.domain
  description = "The SES domain identity used for email reception."
}

output "ses_verification_token" {
  value = aws_ses_domain_identity.main.verification_token
  description = "The token used for Route 53 domain verification."
}

output "ses_receipt_rule_set_name" {
  value = aws_ses_receipt_rule_set.main.rule_set_name
  description = "The name of the SES receipt rule set."
}

output "ses_receipt_rule_name" {
  value = aws_ses_receipt_rule.store_to_s3.name
  description = "The name of the SES receipt rule that stores emails to S3."  
}

output "s3_bucket_policy_id" {
  value = aws_s3_bucket_policy.allow_ses.id
  description = "The ID of the S3 bucket policy that allows SES to write to the bucket."
}