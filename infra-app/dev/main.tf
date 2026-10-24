
module "networking" {
  source = "../../modules/networking"

  cluster_name = "dev-eks-cluster"
  vpc_cidr = "10.0.0.0/16"
  env = "dev"
}

module "dev_infra_deployment" {
  source = "../../modules/eks"

  vpc_id = module.networking.vpc_id
  private_subnets = module.networking.private_subnets

  cluster_name = "dev-eks-cluster"
  cluster_version = "1.32"

  instance_types = ["t3.small"]
  ami_type = "AL2023_x86_64_STANDARD"

  min_size = 2
  max_size = 3
  desired_size = 2

  env = "dev"
}