variable "environment" {
  type        = string
  description = "The environment name (e.g., dev, prod)"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID where the cluster will be deployed"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for the EKS worker nodes"
}

variable "node_instance_types" {
  type        = list(string)
  description = "EC2 instance types for the worker nodes"
  default     = ["t3.small"]
}

variable "scaling_config" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
  description = "Scaling boundaries for the managed node group"
}
