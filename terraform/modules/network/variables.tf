variable "availability_zones" {
  type = map(string)
}

variable "vpc_cidr_block" {
  type = string
}

variable "full_name" {
  type = string
}

variable "base_tags" {
  type = map(string)
}

variable "nat_eips" {
  type = map(object({
    az         = string
    extra_tags = optional(map(string))
  }))
}

variable "bastion_eips" {
  type = map(object({
    az         = optional(string)
    extra_tags = optional(map(string))
  }))
}

variable "bastion_instances_info" {
  description = "Map of all instances_info output from compute modue"
  type = map(object({
    id         = string
    ami        = string
    public_ip  = string
    private_ip = string
  }))
}

variable "public_subnets" {
  type = map(object({
    cidr_block = string
    extra_tags = optional(map(string))
  }))
}

variable "private_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
    extra_tags        = optional(map(string))
  }))
}
