data "aws_secretsmanager_secret_version" "backend" {
  secret_id = var.backend_secret_id
}

locals {
  backend_secrets = jsondecode(data.aws_secretsmanager_secret_version.backend.secret_string)
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

  repo_names = ["capstone-proshop-frontend", "capstone-proshop-backend", "capstone-proshop-nginx"]

  // Image Scanning for vulnerabilities on push
  image_scan = true
  // Why did we choose AES256? Because it's a widely used encryption standard that provides a good balance between security and performance.
  // KMS would be more secure but adds complexity and cost.
  encryption_type = "AES256"

  // Mutable means you can overwrite tags, Immutable means you cannot
  // An image tag is a mutable reference to an image 
  image_tag_mutability = "MUTABLE"
  lifecycle_policy     = file("${path.module}/../../../modules/ecr/ecr_lifecycle.json")

  tags = {
    Project     = "Capstone-Proshop-v2"
    Environment = "dev"
  }
}


module "eks" {
  source       = "../../../modules/eks"
  cluster_name = "capstone-proshop-eks-dev"
  environment  = var.env

  # We keep the EKS cluster in private frontend subnets because we don't want to expose the cluster to the internet directly.
  subnet_ids           = module.vpc.private_frontend_subnet_ids
  vpc_id               = module.vpc.vpc_id
  backend_secret_id    = var.backend_secret_id
  backend_image_repo   = var.backend_image_repo
  frontend_image_repo  = var.frontend_image_repo
  frontend_replicas    = var.frontend_replicas
  frontend_hpa_min     = var.frontend_hpa_min
  frontend_hpa_max     = var.frontend_hpa_max
  frontend_cpu_request = var.frontend_cpu_request
  frontend_mem_request = var.frontend_mem_request
  frontend_cpu_limit   = var.frontend_cpu_limit
  frontend_mem_limit   = var.frontend_mem_limit

  alb_name = var.alb_name

  backend_replicas    = var.backend_replicas
  backend_hpa_min     = var.backend_hpa_min
  backend_hpa_max     = var.backend_hpa_max
  backend_cpu_request = var.backend_cpu_request
  backend_mem_request = var.backend_mem_request
  backend_cpu_limit   = var.backend_cpu_limit
  backend_mem_limit   = var.backend_mem_limit

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
