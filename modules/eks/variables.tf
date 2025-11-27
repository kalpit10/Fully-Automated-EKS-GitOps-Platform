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

# --- Backend deployment ---
variable "backend_replicas" {
  type = number
}

variable "backend_hpa_min" {
  type = number
}

variable "backend_hpa_max" {
  type = number
}

variable "backend_cpu_request" {
  type = string
}

variable "backend_mem_request" {
  type = string
}

variable "backend_cpu_limit" {
  type = string
}

variable "backend_mem_limit" {
  type = string
}



# --- Frontend deployment ---
variable "frontend_replicas" {
  type = number
}

variable "frontend_hpa_min" {
  type = number
}

variable "frontend_hpa_max" {
  type = number
}

variable "frontend_cpu_request" {
  type = string
}

variable "frontend_mem_request" {
  type = string
}

variable "frontend_cpu_limit" {
  type = string
}

variable "frontend_mem_limit" {
  type = string
}


# --- ECR Repositories ---
variable "backend_image_repo" {
  description = "ECR repository name for backend image"
  type        = string
}

variable "frontend_image_repo" {
  description = "ECR repository name for frontend image"
  type        = string
}



# --- ALB ---
variable "alb_name" {
  description = "Name for the AWS Application Load Balancer"
  type        = string
}


variable "backend_secret_id" {
  description = "Name or ARN of the Secrets Manager secret for backend environment variables"
  type        = string
}


variable "node_sg_id" {
  description = "Security Group ID for the EKS worker nodes"
  type        = string
}
