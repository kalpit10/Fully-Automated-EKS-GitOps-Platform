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

variable "alb_name_prefix" {
  description = "Stable substring of the LBC-generated ALB name for CloudWatch SEARCH expressions. Use 'k8s-proshop' — this prefix is stable across redeployments."
  type        = string
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
}

variable "notification_email" {
  description = "Email address to receive CloudWatch Alarm SNS notifications"
  type        = string
}

# variable "cluster_admin_arn" {
#   description = "IAM ARN of the cluster administrator"
#   type        = string
# }
