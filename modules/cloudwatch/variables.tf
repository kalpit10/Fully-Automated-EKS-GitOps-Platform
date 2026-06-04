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
  description = "Stable substring of the LBC-generated ALB name used to scope CloudWatch SEARCH expressions. The LBC names ALBs as k8s-<namespace>-<ingress>-<hash>. Set this to the stable prefix, e.g. 'k8s-proshop', so SEARCH matches the correct ALB regardless of hash suffix changes on redeploy."
  type        = string
}

variable "notification_email" {
  description = "Email address for CloudWatch Alarm SNS notifications"
  type        = string
}
