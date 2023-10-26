terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.44.0"
    }
  }

  required_version = ">= 1.3.7"

  # Uncomment after creating the bucket
  # backend "s3" {
  #   bucket = "tfstate-bucket"
  #   key    = "terraform/state/bootstrap"
  #   region = "${var.region}"
  # }
}

module "image_scanner_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "image-scanner-vpc"
  cidr = "192.168.30.0/26"

  azs             = ["ca-central-1a"]
  private_subnets = ["192.168.30.0/28"]
  public_subnets  = ["192.168.30.32/28"]

  enable_nat_gateway = var.activate_nat_gateway
  single_nat_gateway = var.activate_nat_gateway
  one_nat_gateway_per_az = false
  enable_vpn_gateway = false
  map_public_ip_on_launch = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "image_scanner_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "image-scanner"
  description = "Security group for Data and ML server"
  vpc_id      = module.image_scanner_vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh"
      cidr_blocks = "170.133.228.85/32"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh"
      cidr_blocks = "192.168.30.0/26"
    },
    {
      from_port   = 8088
      to_port     = 8088
      protocol    = "tcp"
      description = "http"
      cidr_blocks = "170.133.228.85/32"
    },
  ]

  egress_with_cidr_blocks = [
    {
        rule        = "all-all"
        cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "front_end_ec2" {
  create = var.create_front_end_server

  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.4"

  name = "front_end"

  ami                    = "ami-0ea18256de20ecdfc"
  instance_type          = "t2.micro"
  key_name               = "andy-key"
  monitoring             = true

  vpc_security_group_ids = [module.image_scanner_sg.security_group_id]
  subnet_id              = module.image_scanner_vpc.public_subnets[0]
  user_data              = "${file("./scripts/host_preparation.sh")}"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "back_end_ec2" {
  create = var.create_back_end_server

  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.4"

  name = "back_end"

  ami                    = "ami-0ea18256de20ecdfc"
  instance_type          = "t2.micro"
  key_name               = "andy-key"
  monitoring             = true

  vpc_security_group_ids = [module.image_scanner_sg.security_group_id]
  subnet_id              = module.image_scanner_vpc.private_subnets[0]
  user_data              = "${file("./scripts/host_preparation.sh")}"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}