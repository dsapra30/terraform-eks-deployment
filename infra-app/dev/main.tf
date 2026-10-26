# 1. Spin up the native custom VPC
module "vpc" {
  source = "../../modules/networking"

  env          = "dev"
  cluster_name         = "dev-core-cluster"
  vpc_cidr             = "10.10.0.0/16"
  public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]
}

# 2. Pipe the custom VPC outputs straight into your custom EKS cluster
module "eks" {
  source = "../../modules/eks"

  environment        = "dev"
  cluster_name       = "dev-core-cluster"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  node_instance_types = ["t3.small"]
  scaling_config = {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
}
