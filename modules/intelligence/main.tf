# 1. The Trust Relationship
resource "aws_iam_role" "processor_role" {
  name = "${var.project_name}-processor-role"
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# 2. The Permissions
resource "aws_iam_role_policy" "ai_access" {
  name = "AIAccessPolicy"
  role = aws_iam_role.processor_role.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "textract:AnalyzeDocument",
          "bedrock:InvokeModel",
          "dynamodb:PutItem",
          "s3:GetObject"
        ]
        Resource = "*" # Textract and Bedrock often require wildcard for basic calls
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem"]
        Resource = [var.dynamodb_arn]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = ["${var.bucket_arn}/*"]
      },
      # Allows Lambda to write logs for debugging and monitoring
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# 3. The Processor Lambda
resource "aws_lambda_function" "processor" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  function_name    = "${var.project_name}-processor"
  role             = aws_iam_role.processor_role.arn
  handler          = "processor.lambda_handler" 
  runtime          = "python3.11"
  timeout          = 60 # AI calls take longer than standard code

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_name
    }
  }

  tags = var.tags
}

# 4. Permissions for Lambda to be invoked by S3
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket_arn
}

# 5. Zip Logic
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../../scripts/processor.py"
  output_path = "${path.module}/../../scripts/processor.zip"
}