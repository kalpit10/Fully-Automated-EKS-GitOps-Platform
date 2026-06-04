module "vpc" {
  source       = "../../../modules/vpc"
  env          = var.env
  name_prefix  = var.name_prefix
  vpc_cidr     = var.vpc_cidr
  subnets      = var.subnets
  region       = var.region
  cluster_name = "proshop-eks-prod" # feeds the kubernetes.io/cluster/* tags
}


module "ecr" {
  source = "../../../modules/ecr"

  repo_names = [
    "proshop-frontend-prod",
    "proshop-backend-prod"
  ]

  image_scan      = true
  encryption_type = "AES256"
  # Mutable only for dev, Immutable for prod to ensure production images are not overwritten.
  image_tag_mutability = "IMMUTABLE"
  lifecycle_policy     = file("${path.module}/../../../modules/ecr/ecr_lifecycle.json")

  tags = {
    Project     = "proshop-v2"
    Environment = "prod"
  }
}

module "eks" {
  source       = "../../../modules/eks"
  cluster_name = "proshop-eks-prod"
  environment  = var.env

  subnet_ids        = module.vpc.private_frontend_subnet_ids
  vpc_id            = module.vpc.vpc_id
  backend_secret_id = var.backend_secret_id

  node_desired_size = var.node_desired_size
  node_min_size     = var.node_min_size
  node_max_size     = var.node_max_size
  node_sg_id        = module.vpc.nodes_sg_id
  # cluster_admin_arn = var.cluster_admin_arn
}

module "cloudwatch" {
  source = "../../../modules/cloudwatch"

  region             = var.region
  cluster_name       = module.eks.cluster_name
  namespace          = "proshop"
  env                = var.env
  alb_name_prefix    = var.alb_name_prefix
  notification_email = var.notification_email
}
