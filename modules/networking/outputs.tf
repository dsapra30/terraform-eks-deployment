output "vpc_id" {
  description = "The ID of the custom VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs for EKS nodes"
  value       = module.vpc.private_subnets
}
