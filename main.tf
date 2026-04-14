terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "networking" {
  source          = "./modules/networking"
  project_name    = var.project_name
  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  tags            = var.tags
  hosted_zone_id  = var.hosted_zone_id
  domain_name     = var.domain_name
  aws_region      = "us-west-1"
  ses_verification_token = module.ingestion.ses_verification_token
}

module "storage" {
  source       = "./modules/storage"
  project_name = var.project_name
  tags         = var.tags  
}

module "intelligence" {
  source          = "./modules/intelligence"

  project_name    = var.project_name
  tags            = var.tags

  # Passing outputs from other modules as variables
  vpc_id          = module.networking.vpc_id
  private_subnets = module.networking.private_subnets
  
  # Handshake: The Lambda needs to know which DB and Bucket to talk to
  dynamodb_name   = module.storage.table_name
  dynamodb_arn    = module.storage.table_arn
  bucket_arn      = module.storage.bucket_arn
}

module "ingestion" {
  source          = "./modules/ingestion"

  project_name    = var.project_name
  tags            = var.tags

  kms_key_arn = module.storage.kms_key_arn
  domain_name = var.domain_name

  lambda_role_arn = module.intelligence.lambda_role_arn
  intelligence_bucket_id = module.storage.bucket_id
}