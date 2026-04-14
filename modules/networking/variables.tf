variable "project_name" {
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

variable "tags" {
    type = map(string) 
}

variable "domain_name" {
    type = string
}

variable "hosted_zone_id" {
    type = string
}

variable "aws_region" {
    type = string  
}

variable "ses_verification_token" {
    type = string  
}
