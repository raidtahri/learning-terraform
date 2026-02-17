variable "project" {
     type = string
}

variable "environment" {
    type = string
  
}

variable "availability_zones" {
    type = map(string)
}

variable "vpc_cidr_block" {
    type = string
}

variable "public_subnets" {
    type = map(object({
        cidr_block = string
        extra_tags = optional(map(string))
    }))
}

variable "nat_eips" {
    type = map(object({
        az = string
        extra_tags = optional(map(string))
    }))
}

variable "bastion_eips" {
    type = map(object({
        az = optional(string)
        extra_tags = optional(map(string))
    }))
}
variable "private_subnets" {
    type = map(object({
        cidr_block = string
        availability_zone = string
        extra_tags = optional(map(string))
    }))
}

variable "bastion_allowed_cidrs" {
  type = list(string)
}
variable "public_key_path" {
     type = string
}

variable "instances" {
     type = map(object({
         instance_type        = string
         subnet_role          = string
         iam_instance_profile = optional(string)
         script_name          = optional(string)
         extra_tags           = optional(map(string), {})
     }))
 }

 variable "ami_owners" {
     type = list(string)
 }

 variable "ami_name_pattern" {
     type = string
 }


