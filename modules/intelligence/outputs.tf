output "lambda_function_arn" {
  value = aws_lambda_function.processor.arn
}

output "lambda_role_arn" {
  value = aws_iam_role.processor_role.arn
}