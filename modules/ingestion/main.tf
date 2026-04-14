# 1. The Landing Zone for Raw Emails
resource "aws_s3_bucket" "email_inbox" {
  bucket = "${var.project_name}-raw-emails"
  force_destroy = true
  tags = var.tags
}

# 2. SES Domain Identity (The "Verification")
resource "aws_ses_domain_identity" "main" {
  domain = var.domain_name
}

# 3. SES Receipt Rule Set (The "Mailbox")
resource "aws_ses_receipt_rule_set" "main" {
  rule_set_name = "${var.project_name}-rules"
}

resource "aws_ses_active_receipt_rule_set" "main" {
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
}

# 4. The "S3 Action" - This is the trigger!
resource "aws_ses_receipt_rule" "store_to_s3" {
  name          = "StoreMedicalScans"
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
  recipients    = ["inbox@${var.domain_name}"]
  enabled       = true
  scan_enabled  = true # Virus/Spam check
  tls_policy    = "Require" # Enforce TLS for secure email reception

  s3_action {
    bucket_name = aws_s3_bucket.email_inbox.id    
    kms_key_arn = var.kms_key_arn 
    # SECURITY LOCK: Encrypt the file immediately using a KMS Key
    position    = 1
  }
}

# 5. The Janitor Lambda (The cleaner)
resource "aws_lambda_function" "janitor" {
# This tells the Lambda to use the zip we just created
  filename         = data.archive_file.janitor_zip.output_path
  source_code_hash = data.archive_file.janitor_zip.output_base64sha256
  function_name    = "${var.project_name}-janitor"
  role             = var.lambda_role_arn
  handler          = "janitor_function.lambda_handler"
  runtime          = "python3.11"

  environment {
    variables = {
      DEST_BUCKET = var.intelligence_bucket_id
      KMS_KEY_ID  = var.kms_key_arn
    }
  }
}

# 6. S3 Bucket Policy - Let SES write to the bucket
resource "aws_s3_bucket_policy" "allow_ses" {
  bucket = aws_s3_bucket.email_inbox.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Sid       = "AllowSESPut"
      Effect    = "Allow"
      Principal = { Service = "ses.amazonaws.com" }
      Action    = "s3:PutObject"
      Resource  = "${aws_s3_bucket.email_inbox.arn}/*"
      Condition = {
        StringEquals = { "aws:Referer" = data.aws_caller_identity.current.account_id }
      }
    }]
  })
}

# 7. S3 Lambda Janitor Function Trigger
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.janitor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.email_inbox.arn
}

# 8. Trigger to notify the Janitor Lambda when a new email lands in the S3 bucket
resource "aws_s3_bucket_notification" "janitor" {
  bucket = aws_s3_bucket.email_inbox.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.janitor.arn
    events              = ["s3:ObjectCreated:*"]
  }
  
  depends_on = [aws_lambda_permission.allow_s3]
}

# 9. Zip up the Janitor Lambda code (This is a local action, not an AWS resource)
data "archive_file" "janitor_zip" {
  type        = "zip"
  source_file = "${path.module}/../../scripts/janitor_function.py" 
  output_path = "${path.module}/../../scripts/janitor_function.zip"
}

# 10. Outputs for other modules to reference
data "aws_caller_identity" "current" {}