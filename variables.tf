provider "aws" {
  region = var.aws_region
}

variable "project_name" {
  type        = string
  description = "The name of the medical office or project"
}

variable "tags" {
  type        = map(string)
  description = "Common tags for resource tracking"
  default = {
    ManagedBy = "Terraform"
    Service   = "Altan-ACAI-Core"
  }
}

variable "hosted_zone_id" {
  type    = string
  default = "" # This prevents the "Required attribute" error
}

variable "aws_region" {
  type        = string
  description = "The AWS region where resources will be created"
}

variable "domain_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}