
locals {
  region_short = "en1"
  full_name = "${var.project}-${var.environment}-${local.region_short}"
  base_tags = {
    Environment = var.environment
    InfrastructureOwner = "devops-team" #you can add ServiceOwner to definr who is responsible for the service logic and maintenance
    Project = var.project #for aws console visibility and filtering
    ManagedBy = "terraform" #to warn other engineers that this resource is managed by terraform and should not be modified manually
  }
}

module "network" {
    source = "../../../modules/network/"
    vpc_cidr_block = var.vpc_cidr_block
    full_name = local.full_name
    base_tags = local.base_tags
    public_subnets = var.public_subnets
    nat_eips = var.nat_eips
    bastion_eips = var.bastion_eips
    server_infos = module.compute.server_infos
    availability_zones = var.availability_zones
    private_subnets = var.private_subnets
/*Module argument names must exactly match the variable names in the child module.
vpc-id is an argument for myapp-subnet module and a variable for subnet child module*/
}

module "compute" {
    source = "../../../modules/compute/"
    full_name = local.full_name
    base_tags = local.base_tags
    vpc_id = module.network.vpc_id
    ami_owners = var.ami_owners
    ami_name_pattern = var.ami_name_pattern
    instances = var.instances
    security_groups = var.security_groups
    public_key_path = var.public_key_path
    subnets_groups = module.network.subnets_groups
}
