terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

  }
  backend "s3" {
    bucket = "test-anlorn-proxy-fun"
    key="tfstate/"
    region="us-east-1"
  }
  required_version = "~> 1.0"

}

provider "aws" {
  region = "us-east-1"
}

module "aws_network" {
  source = "./modules/network"

  region = var.region
  name_prefix = random_pet.name.id
}


resource "random_pet" "name" {

}


data "aws_ami" "worker_ami" {
  most_recent = true
  filter {
    name = "architecture"
    values = ["arm64"]
  }
  filter {
    name = "name"
    values = ["*ubuntu*"]
  }

}

resource "aws_instance" "worker" {
  ami = data.aws_ami.worker_ami.id
  instance_type = "t4g.micro"
  get_password_data = true
  subnet_id = module.aws_network.public_subnet_id
  security_groups = [module.aws_network.allow_ssh_sg_id]
  tags = {
    Name = "worker-${random_pet.name.id}"
  }
}
