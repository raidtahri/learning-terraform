output "vpc_id" {
  value = module.network.vpc_id
}
output "public_subnet_ids" {
  value = module.network.subnets_groups["public"]
}

output "private_app_subnet_ids" {
  value = module.network.subnets_groups["app"]
}

output "private_db_subnet_ids" {
  value = module.network.subnets_groups["db"]
}

output "bastion1_server_infos" {
  value = module.compute.bastion_instances_info["bastion1"]
}
output "app1_server_infos" {
  value = module.compute.app_instances_info["app1"]
}
output "app2_server_infos" {
  value = module.compute.app_instances_info["app2"]
}

output "bastion_eip" {
  value = module.network.bastion_eip
}



