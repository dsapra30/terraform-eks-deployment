variable "cluster_name" {
  description = "The name of the EKS cluster"
  type = string
}

variable "cluster_version" {
  description = "The kubernetes cluster to deploy"
  type = string
  default = "1.32"
}

variable "vpc_id" {
  description = "The ID of the VPC passed from the networking module"
  type        = string
}

variable "private_subnets" {
  description = "The private subnets passed from the networking module"
  type        = list(string)
}

variable "env" {
  description = "Target environment"
  type = string
  default = "dev"
}

variable "ami_type" {
  description = "The image type for worker nodes group"
  type = string
}

variable "instance_types" {
  description = "The instance type for worker node group"
  type = list(string)
}

variable "min_size" {
  description = "The minimum number of nodes"
  type = number
  default = 2
}

variable "max_size" {
  description = "The max number of nodes"
  type = number
  default = 3
}

variable "desired_size" {
  description = "The max number of nodes"
  type = number
  default = 2
}