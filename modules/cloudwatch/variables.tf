variable "region" {
  description = "AWS region where the cluster and ALB run"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace to monitor"
  type        = string
  default     = "proshop"
}

variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "alb_name" {
  description = "Stable part of the ALB name or DNS used to search ALB metrics"
  type        = string
}
