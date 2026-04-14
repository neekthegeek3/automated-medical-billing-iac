variable "project_name" {
    type        = string
    description = "A unique name for the project, used in resource naming."
}

variable "domain_name" {
    type        = string
    description = "The domain name for the SES identity."
}

variable "tags" {
    type = map(string)
}

variable "kms_key_arn" {
    type        = string
    description = "The ARN of the KMS Key used to encrypt emails in S3." 
}

variable "lambda_role_arn" {
    type        = string
    description = "The ARN of the IAM Role that the Janitor Lambda function will assume."
}

variable "intelligence_bucket_id" {
    type        = string
    description = "The name of the S3 bucket where the Janitor Lambda will move processed emails."  
}
