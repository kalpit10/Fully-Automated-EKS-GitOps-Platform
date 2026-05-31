env         = "dev"
name_prefix = "proshop"
vpc_cidr    = "10.0.0.0/16"
region      = "us-east-1"

subnets = {
  public-a = {
    cidr = "10.0.1.0/24"
    az   = "us-east-1a"
    tier = "public"
  }
  public-b = {
    cidr = "10.0.2.0/24"
    az   = "us-east-1b"
    tier = "public"
  }
  private-frontend-a = {
    cidr = "10.0.11.0/24"
    az   = "us-east-1a"
    tier = "private-frontend"
  }
  private-frontend-b = {
    cidr = "10.0.12.0/24"
    az   = "us-east-1b"
    tier = "private-frontend"
  }
  private-backend-a = {
    cidr = "10.0.21.0/24"
    az   = "us-east-1a"
    tier = "private-backend"
  }
  private-backend-b = {
    cidr = "10.0.22.0/24"
    az   = "us-east-1b"
    tier = "private-backend"
  }
}

#### MODULE: EKS ####
# Node group scaling
node_desired_size  = 2
node_min_size      = 1
node_max_size      = 3
node_instance_type = "t3.medium"

# ALB
alb_name = "proshop-alb-dev"

backend_secret_id = "proshop/backend"

# cluster_admin_arn = "arn:aws:iam::395136123952:user/terraform-user"