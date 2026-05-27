terraform {
  required_version = "= 1.12.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket       = "proshop-tfstate-395136123952-use1"
    key          = "envs/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true # SSE-S3 encryption
    use_lockfile = true
  }
}
