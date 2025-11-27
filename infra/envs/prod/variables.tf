variable "env" {
  description = "Environment name (dev or prod)"
  type        = string
}

variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnets" {
  description = "Subnet definitions for this environment"
  type = map(object({
    cidr = string
    az   = string
    tier = string
  }))
}

variable "backend_secret_id" {
  description = "Name or ARN of the Secrets Manager secret for backend environment variables"
  type        = string
}

variable "backend_image_repo" {
  description = "ECR repository name for backend image"
  type        = string
}

variable "frontend_image_repo" {
  description = "ECR repository name for frontend image"
  type        = string
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

variable "alb_name" {
  description = "Name for the AWS Application Load Balancer"
  type        = string
}
