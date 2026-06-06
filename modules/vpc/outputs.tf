# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

# All subnet IDs
output "subnet_ids" {
  description = "All subnet IDs"
  value       = { for k, s in aws_subnet.this : k => s.id }
}

# Public subnet IDs
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for k, s in aws_subnet.this : s.id if var.subnets[k].tier == "public"]
}

# Private frontend subnet IDs
output "private_frontend_subnet_ids" {
  description = "List of private frontend subnet IDs"
  value       = [for k, s in aws_subnet.this : s.id if var.subnets[k].tier == "private-frontend"]
}

# Private backend subnet IDs
output "private_backend_subnet_ids" {
  description = "List of private backend subnet IDs"
  value       = [for k, s in aws_subnet.this : s.id if var.subnets[k].tier == "private-backend"]
}

# Security groups
output "alb_sg_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "nodes_sg_id" {
  description = "Node security group ID"
  value       = aws_security_group.nodes.id
}

output "vpc_endpoints_sg_id" {
  description = "Security group ID for VPC interface endpoints"
  value       = aws_security_group.vpc_endpoints.id
}

output "eks_endpoint_id" {
  description = "VPC endpoint ID for EKS"
  value       = aws_vpc_endpoint.eks.id
}
