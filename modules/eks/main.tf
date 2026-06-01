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

  # Explicitly set authentication mode to API
  # and grant the cluster creator admin permissions automatically
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
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

# Grant the IAM entity that runs Terraform admin access to the cluster.
# This must be created before the node group so nodes can register.
# resource "aws_eks_access_entry" "cluster_admin" {
#   cluster_name  = aws_eks_cluster.this.name
#   principal_arn = var.cluster_admin_arn
#   type          = "STANDARD"

#   depends_on = [aws_eks_cluster.this]
# }

# resource "aws_eks_access_policy_association" "cluster_admin" {
#   cluster_name  = aws_eks_cluster.this.name
#   principal_arn = var.cluster_admin_arn
#   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

#   access_scope {
#     type = "cluster"
#   }

#   depends_on = [aws_eks_access_entry.cluster_admin]
# }

#############################
# MANAGED NODE GROUP
# This creates worker nodes for the EKS cluster
#############################

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  instance_types = [var.node_instance_type]
  capacity_type  = "ON_DEMAND"

  # Attach both the custom node security group AND the cluster security group
  # The cluster security group enables control plane to node communication
  # Without it nodes cannot register with the Kubernetes API server
  launch_template {
    name    = aws_launch_template.nodes.name
    version = aws_launch_template.nodes.latest_version
  }

  tags = {
    Name = "${var.cluster_name}-ng"
  }

  depends_on = [
    aws_eks_cluster.this
  ]
}

# Launch template is used to specify additional configuration for the EC2 instances that will be launched as worker nodes in the EKS cluster.
# We are using it to attach both the custom node security group and the cluster security group to ensure proper communication between the control plane and the nodes.
resource "aws_launch_template" "nodes" {
  name_prefix = "${var.cluster_name}-node-"

  vpc_security_group_ids = [
    var.node_sg_id,
    aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  ]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-node"
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
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

# resource "aws_eks_addon" "cloudwatch_observability" {
#   cluster_name = aws_eks_cluster.this.name # change "this" to your real cluster resource name
#   addon_name   = "amazon-cloudwatch-observability"

#   # This setting ensures that if there are updates to the addon configuration,
#   # it will overwrite the existing configuration instead of failing.
#   resolve_conflicts_on_update = "OVERWRITE"

#   tags = {
#     Name        = "cloudwatch-observability-${aws_eks_cluster.this.name}"
#     Environment = var.environment # if your eks module has environment variable
#   }
# }


# ------ EBS CSI DRIVER ADDON ------
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.this.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_role.arn

  # OVERWRITE ensures that if a previous manual installation of the driver
  # exists (e.g. from kubectl apply), Terraform takes ownership without failing.
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Name        = "ebs-csi-driver-${var.cluster_name}"
    Environment = var.environment
  }

  depends_on = [
    aws_eks_node_group.this,
    aws_iam_role_policy_attachment.ebs_csi_policy
  ]
}
