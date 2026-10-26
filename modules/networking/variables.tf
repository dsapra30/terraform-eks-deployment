variable "cluster_name" {
  description = "The name of the eks cluster"
  type = string
}

variable "vpc_cidr" {
  description = "The CIDR for VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "The CIDR for Public VPC"
  type = list(string)
}

variable "private_subnet_cidrs" {
  description = "The CIDR for Private VPC"
  type = list(string)
}

variable "env" {
  description = "Target environment"
  type = string
  default = "dev"
}