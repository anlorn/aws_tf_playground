terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

  }
  backend "s3" {
    bucket = "test-anlorn-proxy-fun"
    key="tfstate"
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

locals {
  asg_tag_name = "ControlledBy"
}


resource "random_pet" "name" {

}


data "aws_ami" "worker_ami" {
  most_recent = true
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
  filter {
    name = "description"
    values = ["Amazon Linux*2023*AMI*HVM*"]
  }

}

resource "aws_launch_template" "this" {
  name = "lt-${replace(random_pet.name.id, "-", "")}"
  image_id = data.aws_ami.worker_ami.id
  instance_type = data.aws_ami.worker_ami.architecture == "x86_64" ? "t2.medium" : "t4g.medium"
  vpc_security_group_ids = [module.aws_network.allow_ssh_sg_id]
  key_name = aws_key_pair.deployer.key_name
  user_data = filebase64("${path.module}/scripts/startup.sh")
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${random_pet.name.id}"
    }
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "${random_pet.name.id}-deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_autoscaling_group" "this" {
  name = "asg-${random_pet.name.id}"
  min_size = 1
  max_size = 1
  desired_capacity = 1
  launch_template {
    id = aws_launch_template.this.id
    version = "$Latest"
  }
  vpc_zone_identifier = [module.aws_network.public_subnet_id]
  tag {
      key = local.asg_tag_name
      value = aws_launch_template.this.name
      propagate_at_launch = true
    }
}

data aws_instances "this" {
  filter {
    name = "tag:${local.asg_tag_name}"
    values = [aws_launch_template.this.name]
  }
  # To ensure that EC2 instances launched when we query here
  depends_on = [aws_autoscaling_group.this]
}


// TODO: Read 1password secrets with TAG x and put them to secrets manager
// Read secrets manager in EC2 instances
