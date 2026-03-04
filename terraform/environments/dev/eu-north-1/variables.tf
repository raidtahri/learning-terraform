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
variable "private_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
    extra_tags        = optional(map(string))
  }))
}

variable "bastion_allowed_cidrs" {
  type = list(string)
}

variable "app_instances" {
  type = map(object({ #object when each element has diffirent types -string, boolean, number,etc.-
    instance_type        = string
    subnet_role          = string
    subnet_az            = string
    iam_instance_profile = optional(string)
    script_name          = optional(string)
    extra_tags           = optional(map(string), {}) #string when each element has same type -string-
  }))
}
variable "bastion_instances" {
  type = map(object({ #object when each element has diffirent types -string, boolean, number,etc.-
    instance_type        = string
    subnet_role          = string
    subnet_az            = string
    iam_instance_profile = optional(string)
    script_name          = optional(string)
    extra_tags           = optional(map(string), {}) #string when each element has same type -string-
  }))
}

variable "ami_owners" {
  type = list(string)
}

variable "ami_name_pattern" {
  type = string
}

variable "jenkins_instances" {
  type = map(object({
    instance_type        = string
    subnet_role          = string
    subnet_az            = string
    iam_instance_profile = optional(string)
    script_name          = optional(string)
    extra_tags           = optional(map(string), {})
  }))
}
variable "jenkins_ami_owners" {
  type = list(string)
}

variable "jenkins_ami_name_pattern" {
  type = string
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 30
}
variable "public_key_path" {
  description = "Path to the public key file for SSH access"
  type        = string
}