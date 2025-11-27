data "aws_secretsmanager_secret_version" "backend" {
  secret_id = var.backend_secret_id
}


module "vpc" {
  source      = "../../../modules/vpc"
  env         = var.env
  name_prefix = var.name_prefix
  vpc_cidr    = var.vpc_cidr
  subnets     = var.subnets
}


module "ecr" {
  source = "../../../modules/ecr"

  repo_names = [
    "capstone-proshop-frontend-prod",
    "capstone-proshop-backend-prod",
    "capstone-proshop-nginx-prod"
  ]

  image_scan      = true
  encryption_type = "AES256"
  # Mutable only for dev, Immutable for prod to ensure production images are not overwritten.
  image_tag_mutability = "IMMUTABLE"
  lifecycle_policy     = file("${path.module}/../../../modules/ecr/ecr_lifecycle.json")

  tags = {
    Project     = "Capstone-Proshop-v2"
    Environment = "prod"
  }
}

module "eks" {
  source       = "../../../modules/eks"
  cluster_name = "capstone-proshop-eks-prod"
  environment  = var.env

  subnet_ids          = module.vpc.private_frontend_subnet_ids
  vpc_id              = module.vpc.vpc_id
  backend_secret_id   = var.backend_secret_id
  backend_image_repo  = var.backend_image_repo
  frontend_image_repo = var.frontend_image_repo

  frontend_replicas    = var.frontend_replicas
  frontend_hpa_min     = var.frontend_hpa_min
  frontend_hpa_max     = var.frontend_hpa_max
  frontend_cpu_request = var.frontend_cpu_request
  frontend_mem_request = var.frontend_mem_request
  frontend_cpu_limit   = var.frontend_cpu_limit
  frontend_mem_limit   = var.frontend_mem_limit

  backend_replicas    = var.backend_replicas
  backend_hpa_min     = var.backend_hpa_min
  backend_hpa_max     = var.backend_hpa_max
  backend_cpu_request = var.backend_cpu_request
  backend_mem_request = var.backend_mem_request
  backend_cpu_limit   = var.backend_cpu_limit
  backend_mem_limit   = var.backend_mem_limit

  alb_name = var.alb_name

  node_desired_size = var.node_desired_size
  node_min_size     = var.node_min_size
  node_max_size     = var.node_max_size
  node_sg_id        = module.vpc.nodes_sg_id
}

module "cloudwatch" {
  source = "../../../modules/cloudwatch"

  region       = var.region
  cluster_name = module.eks.cluster_name
  namespace    = "proshop"
  env          = var.env
  alb_name     = var.alb_name
}

module "secrets" {
  source = "../../../modules/secrets"
}
