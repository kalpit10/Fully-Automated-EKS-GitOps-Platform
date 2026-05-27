env         = "prod"
name_prefix = "proshop"
vpc_cidr    = "10.1.0.0/16"
region      = "us-east-1"

subnets = {
  public-a = {
    cidr = "10.1.1.0/24"
    az   = "us-east-1a"
    tier = "public"
  }
  public-b = {
    cidr = "10.1.2.0/24"
    az   = "us-east-1b"
    tier = "public"
  }
  private-frontend-a = {
    cidr = "10.1.11.0/24"
    az   = "us-east-1a"
    tier = "private-frontend"
  }
  private-frontend-b = {
    cidr = "10.1.12.0/24"
    az   = "us-east-1b"
    tier = "private-frontend"
  }
  private-backend-a = {
    cidr = "10.1.21.0/24"
    az   = "us-east-1a"
    tier = "private-backend"
  }
  private-backend-b = {
    cidr = "10.1.22.0/24"
    az   = "us-east-1b"
    tier = "private-backend"
  }
}

#### MODULE: EKS ####
# Node group scaling
node_desired_size  = 3
node_min_size      = 2
node_max_size      = 5
node_instance_type = "t3.large"

# ALB
alb_name = "proshop-alb-prod"

backend_secret_id = "proshop/backend-prod"
