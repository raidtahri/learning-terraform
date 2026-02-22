output "bastion_instances_info" {
  value = {
    for name, instance in aws_instance.bastion :
    name => {
    id         = instance.id
    ami        = instance.ami
    public_ip  = instance.public_ip
    private_ip = instance.private_ip
    }
  }
}

output "app_instances_info" {
  value = {
    for name, instance in aws_instance.app :
    name => {
      id         = instance.id
      ami        = instance.ami
      private_ip = instance.private_ip
    }
  }
}
