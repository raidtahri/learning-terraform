variable "full_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "base_tags" {
  type = map(string)
}

variable "bastion_sg_id" {
  type = string
}

variable "public_key_path" {
  type = string
}

variable "jenkins_instances" {
  type = map(object({ #object when each element has diffirent types -string, boolean, number,etc.-
    instance_type        = string
    subnet_role          = string
    subnet_az            = string
    iam_instance_profile = optional(string)
    script_name          = optional(string)
    extra_tags           = optional(map(string), {}) #string when each element has same type -string-
  }))
}


variable "jenkins_ami_owners" {
  type = list(string)
}

variable "jenkins_ami_name_pattern" {
  type = string
}
variable "subnets_groups" {
  description = "subnets grouped by role from natwork module"
  type        = map(map(string))
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 30
}

