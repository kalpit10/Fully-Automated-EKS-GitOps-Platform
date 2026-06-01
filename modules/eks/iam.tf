#############################
# IAM ROLES FOR EKS
#############################

# --- Cluster Role ---
# Assume role policy for EKS cluster. This allows EKS to manage AWS resources on our behalf.
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach managed policy to cluster role
# Now we attach the AmazonEKSClusterPolicy to the EKS cluster role.
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# --- Node Role ---
# This role will be assumed by the EC2 instances (worker nodes) in the EKS cluster.
resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach required policies to node role
# Here, we are actually attaching multiple policies to the node role using a for_each loop.

# AmazonEKSWorkerNodePolicy	Allows nodes to communicate with EKS
# AmazonEC2ContainerRegistryReadOnly	Lets nodes pull images from ECR
# AmazonEKS_CNI_Policy	Allows networking for pods
# CloudWatchAgentServerPolicy	Lets nodes send logs/metrics to CloudWatch
resource "aws_iam_role_policy_attachment" "node_policies" {
  # Toset creates a set from the list of policy ARNs which makes it easier to iterate over them
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ])
  role       = aws_iam_role.eks_node_role.name
  policy_arn = each.key
}

###############################################
# IAM POLICY FOR AWS LOAD BALANCER CONTROLLER
###############################################

# Downloaded from official AWS EKS docs
# https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/install/iam_policy.json

data "aws_iam_policy_document" "alb_controller" {
  statement {
    effect = "Allow"
    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DeleteSecurityGroup",
      "ec2:Describe*",
      "elasticloadbalancing:*",
      "iam:CreateServiceLinkedRole",
      "iam:GetServerCertificate",
      "iam:ListServerCertificates",
      "cognito-idp:DescribeUserPoolClient",
      "waf-regional:GetWebACLForResource",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "shield:GetSubscriptionState",
      "shield:DescribeProtection",
      "shield:CreateProtection",
      "shield:DeleteProtection",
      "shield:DescribeSubscription",
      "shield:ListProtections"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "alb_controller" {
  name        = "${var.cluster_name}-alb-controller-policy"
  description = "Permissions for AWS Load Balancer Controller"
  policy      = data.aws_iam_policy_document.alb_controller.json
}

###############################################
# IAM ROLE FOR SERVICE ACCOUNT (IRSA) FOR ALB CONTROLLER
# What is a Service Account? It is an identity for pods to interact with AWS resources securely.
# Why IRSA? Because it allows us to assign specific IAM roles to specific pods, enhancing security.
# Why we use it? Before IRSA, pods had to use node IAM roles which gave broad permissions to all pods.
# With IRSA, we can give only the necessary permissions to specific pods.
###############################################

# Role that the controller pod will assume via OIDC
resource "aws_iam_role" "alb_controller_role" {
  name = "${var.cluster_name}-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.this.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            # Replace "amazon-system" with correct namespace later if you use another
            # Ensures only the service account named aws-load-balancer-controller in namespace kube-system can assume this role
            # The syntax meaning is, it is calling OIDC issuer URL after which :sub means subject claim in the token, which actually means the service account can assume this role only.
            "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

# Attach policy created earlier
resource "aws_iam_role_policy_attachment" "alb_controller_attach" {
  role       = aws_iam_role.alb_controller_role.name
  policy_arn = aws_iam_policy.alb_controller.arn
}


############################ IAM + IRSA FLOW EXPLANATION ############################

# 1️⃣  OIDC Provider (already exists from EKS setup)
#     - Lets AWS trust tokens issued by the EKS cluster.
#     - Required so service accounts inside the cluster can assume IAM roles securely.

# 2️⃣  IAM Policy (aws_iam_policy)
#     - Defines WHAT actions the pods are allowed to perform.
#     - Here: only "secretsmanager:GetSecretValue" on the specific secret
#       arn:aws:secretsmanager:us-east-1:<account-id>:secret:proshop/backend-*.

# 3️⃣  IAM Role (aws_iam_role)
#     - Defines WHO can assume the role and under what condition.
#     - The "assume_role_policy" allows assumption only by the OIDC provider
#       when the token subject matches the Kubernetes service account:
#       system:serviceaccount:proshop:backend-sa.

# 4️⃣  IAM Role Policy Attachment (aws_iam_role_policy_attachment)
#     - Connects the above policy to the role.
#     - Without this, the role exists but has no permissions.

# 5️⃣  Kubernetes Service Account (backend-sa)
#     - Created inside the EKS cluster (namespace: proshop).
#     - Annotated with the IAM Role ARN so pods using it automatically get
#       temporary credentials for AWS API access.

# 🔁  Final Result:
#     Backend pods -> run as service account backend-sa ->
#     assume IAM role proshop-backend-irsa-role via OIDC ->
#     use temporary credentials to call Secrets Manager ->
#     securely read proshop/backend secret.

#####################################################################################

resource "aws_iam_policy" "backend_secrets_read" {
  name        = "proshop-backend-secrets-read"
  description = "Allow backend pods to read proshop/backend secret"

  policy = jsonencode({
    Version = "2012-10-17"
    # This policy allows reading the secret values from AWS Secrets Manager for the proshop/backend secret.
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        # This block actually tells us which secret the policy applies to.
        # It applies to any secret that starts with "proshop/backend-" in the current AWS account and region.
        Resource = "arn:aws:secretsmanager:us-east-1:${data.aws_caller_identity.current.account_id}:secret:${var.backend_secret_id}-*"

      }
    ]
  })
}

# This block in simple terms defines the trust relationship for the backend IRSA role.
# What a trust relationship does is, it defines who can assume this role.
data "aws_iam_policy_document" "backend_irsa_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.this.id]

    }

    condition {
      test = "StringEquals"
      # Here, https is used so that it matches the format of the OIDC provider URL.
      # The :sub part means the subject claim in the token, which actually means the service account can assume this role only.
      # So in basic terms, this condition ensures that only the service account named backend-sa in the default namespace can assume this role.
      variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:proshop:backend-sa"]
    }
  }
}

# This resource creates an IAM role for the backend service account to assume via IRSA.
resource "aws_iam_role" "backend_irsa_role" {
  name = "proshop-backend-irsa-role"
  # Here in simple terms, we are defining who can assume this role.
  # This role can be assumed by the backend service account in the proshop namespace.
  assume_role_policy = data.aws_iam_policy_document.backend_irsa_assume.json
}


# In simple terms, this block attaches the policy we created earlier to the backend IRSA role.
resource "aws_iam_role_policy_attachment" "backend_secrets_read_attach" {
  role       = aws_iam_role.backend_irsa_role.name
  policy_arn = aws_iam_policy.backend_secrets_read.arn
}

# ------- EBS CSI DRIVER POLICY -------
# This policy allows the EBS CSI driver to manage EBS volumes for the EKS cluster

resource "aws_iam_role" "ebs_csi_role" {
  name = "${var.cluster_name}-ebs-csi-role"

  # Trust policy: only the EBS CSI controller ServiceAccount in kube-system
  # can assume this role via OIDC WebIdentity.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.this.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

# Attach the AWS-managed EBS CSI policy.
# arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy grants
# the exact EC2 and KMS permissions the driver needs to manage EBS volumes.
resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  role       = aws_iam_role.ebs_csi_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# ------- EXTERNAL SECRETS OPERATOR (ESO) POLICY -------
# This policy allows the ESO to read secrets from AWS Secrets Manager.
resource "aws_iam_policy" "eso_secrets_policy" {
  name = "${var.cluster_name}-eso-secrets-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret", "secretsmanager:ListSecrets"]
        Resource = "arn:aws:secretsmanager:us-east-1:${data.aws_caller_identity.current.account_id}:secret:proshop/*"
      }
    ]
  })
}

resource "aws_iam_role" "eso_role" {
  name = "${var.cluster_name}-eso-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.this.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:external-secrets:external-secrets-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eso_policy_attach" {
  role       = aws_iam_role.eso_role.name
  policy_arn = aws_iam_policy.eso_secrets_policy.arn
}
