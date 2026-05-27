#############################
# EKS CLUSTER
#############################

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  # This is for providing networking configuration for the EKS cluster
  # We specify the VPC subnets where the EKS cluster will be deployed
  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_public_access  = true # allow public API access so we can use kubectl from the terminal (outside).
    endpoint_private_access = true # keep private access for nodes
  }

  # This is for maintaining logs for the EKS cluster
  # basic control plane logs for troubleshooting
  enabled_cluster_log_types = [
    "api",
    "audit",
    "controllerManager",
    "scheduler"
  ]

  tags = {
    Name = var.cluster_name
  }
}


#############################
# MANAGED NODE GROUP
# This creates worker nodes for the EKS cluster
#############################

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-node-group"
  # IAM role allowing EC2 nodes to join and pull images from ECR
  node_role_arn = aws_iam_role.eks_node_role.arn
  subnet_ids    = var.subnet_ids

  # Starts 2 node, scales to 3 if needed
  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  # t3.medium is 2 vCPU and 4 GiB RAM, suitable for general-purpose workloads
  instance_types = [var.node_instance_type] // Why square brackets? Because instance_types expects a list, even if we only provide one type. This allows for future expansion to multiple instance types if needed.
  capacity_type  = "ON_DEMAND"

  tags = {
    Name = "${var.cluster_name}-ng"
  }

  # Ensure the node group is created only after the EKS cluster is fully set up
  depends_on = [
    aws_eks_cluster.this
  ]
}


#############################
# EKS OIDC PROVIDER
# This allows the EKS cluster to integrate with IAM roles for service accounts
# Service accounts are used to grant permissions to pods running in the cluster.
# Why Service Accounts? Because they provide a way to assign specific IAM roles to specific pods, 
# which is more secure and manageable than giving broad permissions to all pods.
# Then those pods can access AWS resources securely.
#############################

# Fetch EKS cluster details to get the OIDC issuer URL
data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.this.name
}


# Fetches the TLS certificate from the OIDC issuer endpoint at plan time.
# The thumbprint is the SHA1 fingerprint of the root CA in the certificate chain.
# This replaces the previously hardcoded value and stays current automatically
# if AWS rotates the certificate.
data "tls_certificate" "eks_oidc" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# This block creates the OIDC provider for the EKS cluster
# What is the OIDC provider? It is a service that allows the EKS cluster to authenticate with IAM roles.
# This lets AWS trust our Kubernetes cluster as an identity source.
# It uses the issuer URL from the EKS cluster data source so that the cluster can authenticate with IAM roles.
resource "aws_iam_openid_connect_provider" "this" {
  url            = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list = ["sts.amazonaws.com"]
  # Dynamically fetched from the issuer endpoint - never hardcoded
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
}

#############################
# CLOUDWATCH DASHBOARD FOR EKS 
# AddOn means additional features provided by AWS for EKS clusters
# CloudWatch Observability AddOn provides enhanced monitoring and observability for EKS clusters
# It will automatically install and configure CloudWatch Container Insights for the cluster
#############################

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name = aws_eks_cluster.this.name # change "this" to your real cluster resource name
  addon_name   = "amazon-cloudwatch-observability"

  # This setting ensures that if there are updates to the addon configuration,
  # it will overwrite the existing configuration instead of failing.
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Name        = "cloudwatch-observability-${aws_eks_cluster.this.name}"
    Environment = var.environment # if your eks module has environment variable
  }
}
