variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "region" {
  description = "AWS region to deploy the EKS cluster"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster is deployed"
  type        = string
}


# --- Node scaling ---
variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "backend_secret_id" {
  description = "Name or ARN of the Secrets Manager secret for backend environment variables"
  type        = string
}

variable "node_sg_id" {
  description = "Security Group ID for the EKS worker nodes"
  type        = string
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}
