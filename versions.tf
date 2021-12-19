terraform {
  backend "s3" {}
  required_version = ">= 0.15"
}

provider "aws" {
  region  = var.aws_region
  version = ">= 3.0.0"
}
