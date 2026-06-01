#############################
# EKS OUTPUTS
# Once the cluster and node group exist, we’ll need its details to connect with kubectl and deploy workloads.
#############################

# Used when running aws eks update-kubeconfig
output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

# API URL for kubectl communication
output "cluster_endpoint" {
  description = "EKS cluster API server endpoint"
  value       = aws_eks_cluster.this.endpoint
}

# Verifies the cluster’s identity to ensure secure communication
output "cluster_certificate_authority" {
  description = "Base64-encoded certificate data"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

# Future IAM role mappings for ALB controller, etc.
output "oidc_provider_arn" {
  description = "OIDC provider ARN"
  value       = aws_iam_openid_connect_provider.this.arn
}

# We need this URL for setting up IRSA
output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.this.url
}

output "ebs_csi_role_arn" {
  description = "IAM role ARN used by the EBS CSI Driver addon via IRSA"
  value       = aws_iam_role.ebs_csi_role.arn
}
