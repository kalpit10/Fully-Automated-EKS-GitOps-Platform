output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "Public subnet IDs for ALB"
}

output "private_subnet_ids" {
  value = concat(
    module.vpc.private_frontend_subnet_ids,
    module.vpc.private_backend_subnet_ids
  )
  description = "All private subnet IDs for EKS"
}

output "alb_sg_id" {
  value       = module.vpc.alb_sg_id
  description = "Security group ID for ALB"
}

output "ecr_repository_names" {
  description = "ECR repository names in the dev environment"
  value       = module.ecr.repository_names
}

output "ecr_repo_urls" {
  value       = module.ecr.repository_uris
  description = "ECR repository URLs"
  sensitive   = true
}
