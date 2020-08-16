terraform {
  required_version = ">= 0.12.18"
}

provider "aws" {
  #version ="~> 2.67"
  #access_key = var.access_key 
  #secret_key = var.secret_key 
  region     = var.location
}