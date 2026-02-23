terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
provider "aws" {
  region = "eu-north-1"
  /* default_tags {
         tags = {
           Environment = dev
           Owner = "devops-team"
           Project = "learning-terraform" #for aws console visibility and filtering
           ManagedBy = "terraform" #to warn other engineers that this resource is managed by terraform and should not be modified manually
         }
    }*/
}

#tags: only shows what you manually add to the resource, while tags_all shows the combination of manually added tags and default tags from the provider configuration. In this case, tags will only show the tags defined in the resource, while tags_all will include those tags plus the default tags from the provider configuration.
#put in mind that ASG resource gas some limitations, because some resources wont apply thes tags, ebs in ec2 resource, ASG creates and manages EC2 instances, and the tags defined in the ASG resource will only be applied to the ASG itself, not to the EC2 instances it creates. To ensure that the EC2 instances created by the ASG also have the desired tags, you need to use the "tag" block within the ASG resource to specify the tags that should be applied to the instances. This way, both the ASG and its instances will have the appropriate tags for better organization and management in AWS. or you can  pull the default tags from the provider configuration using data "aws_default_tags" {} and apply them manually using propagate_at_launch = true in the ASG resource, but it is more straightforward to use the "tag" block within the ASG resource to ensure that the instances are tagged correctly.
#the presedence rule: if you define a tag in the provider configuration and the same tag in the resource configuration, the tag defined in the resource configuration will take precedence over the one defined in the provider configuration for that specific resource. This allows you to have default tags set at the provider level while still being able to override them on a per-resource basis when needed.