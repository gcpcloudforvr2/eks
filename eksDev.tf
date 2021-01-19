provider "aws" {
  region = "us-east-2"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.eks.vpc_id
}

module "eks" {
  source                = "../modules/eks"
  create_vpc			= false
  existing_vpc_id		= "vpc-8d8b78e4"
  name                  = "eks-vpc-example"
  vpc_cidr              = "20.10.0.0/16"
  azs                   = ["us-east-2a", "us-east-2b", "us-east-2c"]
  public_subnets        = ["20.10.11.0/24", "20.10.12.0/24", "20.10.13.0/24"]
  enable_dns_hostnames  = true
  enable_dns_support    = true
  enable_nat_gateway    = true
  single_nat_gateway    = true

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = [{}]
  default_security_group_egress  = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "0.0.0.0/0"
  }]
  cluster_name = "demo"
  node_grp_name = "demoNG1"
  ng_asg_name = "demoASG"
  ng_desired_capacity = 2
  ng_max_capacity = 2
  ng_min_capacity = 1
  ng_ami_type  = "AL2_x86_64"
  ng_instance_type  =  ["t2.micro"]
}
