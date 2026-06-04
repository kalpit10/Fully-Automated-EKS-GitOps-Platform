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

variable "alb_name_prefix" {
  description = "Stable substring of the LBC-generated ALB name used to scope CloudWatch dashboard SEARCH expressions. The LBC names ALBs as k8s-<namespace>-<ingress>-<hash>. Set to 'k8s-proshop' — stable across redeployments."
  type        = string
}

variable "notification_email" {
  description = "Email address for CloudWatch Alarm SNS notifications. Must be confirmed via the subscription email AWS sends after terraform apply."
  type        = string
}

variable "hpa_max_replicas" {
  description = "Maximum replica count configured in the HPA for the proshop namespace. Used as the threshold for the HPA-at-max alarm."
  type        = number
  default     = 3
}
