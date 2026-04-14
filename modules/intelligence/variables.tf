variable "project_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "vpc_id" {
  type = string
  description = "The ID of the VPC passed from the networking module"
}

variable "private_subnets" {
  type = list(string)
}

variable "dynamodb_name" {
  type = string
}

variable "dynamodb_arn" {
  type = string
}

variable "bucket_arn" {
  type = string
}