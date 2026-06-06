variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "env" {
  description = "Environment name (dev, prod, etc.)"
  type        = string
}

variable "subnets" {
  description = "Subnet definitions for the VPC"
  type = map(object({
    cidr = string
    az   = string
    tier = string
  }))
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "region" {
  description = "AWS region - used for VPC endpoint service names"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name — used to tag VPC and subnets for LBC auto-discovery"
  type        = string
}
