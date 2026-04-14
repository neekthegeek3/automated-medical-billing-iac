module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  
  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_dns_support   = true
  enable_dns_hostnames = true
  
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = merge(var.tags, {
    Name        = "${var.project_name}-vpc"
    Environment = "dev"
  })
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = concat(module.vpc.private_route_table_ids, module.vpc.public_route_table_ids)
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-s3-endpoint"
  })
}