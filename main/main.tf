
variable "aws_key" {
}

variable "aws_secret" {
}

terraform {
  required_version = ">= 0.12"

  # keep the backend as s3 for digger
  backend "s3" {}

  required_providers {
    archive = {
      version = "= 1.3.0"
      source  = "hashicorp/archive"
    }

    local = {
      version = "= 1.4.0"
      source  = "hashicorp/local"
    }

    template = {
      version = "= 2.1.2"
      source  = "hashicorp/template"
    }
  }
}


provider "aws" {
  version = ">= 2.27.0, < 3.0.0"
  region  = var.region
  access_key = var.aws_key
  secret_key = var.aws_secret  
}

