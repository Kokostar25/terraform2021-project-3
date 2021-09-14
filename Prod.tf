terraform {

  backend "s3" {
    profile        = "devops-koko"
    bucket         = "koko-1dev"
    key            = "remote/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "globo-tfstatelock-91437"
    encrypt        = true

  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }

  }
}


provider "aws" {
  region  = "us-east-1"
  profile = "devops-koko"

}

module "Prod_Networking" {
  source            = "./module/networking"
  vpc_id            = module.Prod_Networking.Prod-vpc_id
  availability_zone = var.availability_zone
  private_subnet    = var.private_subnet
  public_subnet     = var.public_subnet
}

module "Prod_Resources" {

  source                 = "./module/ec2"
  ec2_keypair            = var.ec2_keypair
  instance_type          = var.instance_type
  subnet_id_1            = module.Prod_Networking.public_subnet_id
  subnet_id_2            = module.Prod_Networking.private_subnet_id
  ec2_ami                = var.ec2_ami
  vpc_id                 = module.Prod_Networking.Prod-vpc_id
  private_subnet         = var.private_subnet
  public_subnet          = var.public_subnet
  vpc_security_group_ids = ["module.Prod_Resources.security_group_public", "module.Prod_Resources.security_group_private"]
  availability_zone      = var.availability_zone
}

