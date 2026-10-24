terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket = "dev-eks-cluster-dev-s3-tfstate"
    key = "terraform.tfstate"
    region = "ap-northeast-1"
    use_lockfile = true
    encrypt = true
  }
}