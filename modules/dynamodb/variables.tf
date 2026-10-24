variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster to interpolate in resource naming"
}

variable "env" {
    description = "The environment for terraform state"
    type = string
}