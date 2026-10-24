module "dynamodb" {
  source = "../../modules/dynamodb"

  cluster_name = "dev-eks-cluster"
  env = "dev"
}

module "s3" {
  source = "../../modules/s3"
  
  cluster_name = "dev-eks-cluster"
  env = "dev"
}