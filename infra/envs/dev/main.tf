module "vpc" {
  source       = "../../../modules/vpc"
  env          = var.env
  name_prefix  = var.name_prefix
  vpc_cidr     = var.vpc_cidr
  subnets      = var.subnets
  region       = var.region
  cluster_name = "proshop-eks-dev" # feeds the kubernetes.io/cluster/* tags
}



module "ecr" {
  source = "../../../modules/ecr"

  repo_names = ["proshop-frontend", "proshop-backend"]

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
    Project     = "proshop-v2"
    Environment = "dev"
  }
}


module "eks" {
  source       = "../../../modules/eks"
  cluster_name = "proshop-eks-dev"
  environment  = var.env

  # We keep the EKS cluster in private frontend subnets because we don't want to expose the cluster to the internet directly.
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
  source             = "../../../modules/cloudwatch"
  alb_name_prefix    = var.alb_name_prefix
  notification_email = var.notification_email

  region            = var.region
  cluster_name      = module.eks.cluster_name
  namespace         = "proshop"
  env               = var.env
  create_alb_alarms = var.create_alb_alarms
}
