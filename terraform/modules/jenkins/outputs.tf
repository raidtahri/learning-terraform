output "jenkins_instances_info" {
  value = {
    for name, instance in aws_instance.jenkins :
    name => {
      id         = instance.id
      ami        = instance.ami
      private_ip = instance.private_ip
    }
  }
}
