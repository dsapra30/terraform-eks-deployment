output "cluster_endpoint" {
  value       = aws_eks_cluster.this.endpoint
  description = "The endpoint for your EKS Kubernetes API."
}

output "cluster_certificate_authority_data" {
  value       = aws_eks_cluster.this.certificate_authority[0].data
  description = "The base64 encoded certificate data required to communicate with your cluster."
}
