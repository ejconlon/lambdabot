variable "profile" {
  type = "string"
  description = "AWS profile"
  default = "_PROFILE_"
}

variable "region" {
  type = "string"
  description = "AWS region"
  default = "_REGION_"
}

variable "project" {
  type = "string"
  description = "Project"
  default = "_PROJECT_"
}

variable "state_bucket" {
  type = "string"
  description = "Terraform state S3 bucket"
  default = "_PROFILE_-terraform"
}

provider "aws" {
  profile = "_PROFILE_"
  region  = "_REGION_"
}

terraform {
  backend "s3" {
    profile = "_PROFILE_"
    region  = "_REGION_"
    bucket  = "_PROFILE_-terraform"
    key     = "_PROJECT_/_COMPONENT_/terraform.tfstate"
  }
}
