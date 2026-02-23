resource "aws_security_group" "bastion" {
  name   = "${var.full_name}-bastion-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.full_name}-bastion-sg"
      Tier = "bastion"
    },
    var.base_tags
  )
}

resource "aws_security_group" "app" {
  name   = "${var.full_name}-app-sg"
  vpc_id = var.vpc_id

  ingress {
    description     = "App port from Bastion"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.full_name}-app-sg"
      Tier = "app"
    },
    var.base_tags
  )
}

data "aws_ami" "this" {
  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "this" {
  key_name   = "${var.full_name}-key"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "bastion" {
  for_each      = var.bastion_instances
  ami           = data.aws_ami.this.id
  instance_type = each.value.instance_type
  #the problem with the approch below is that it works only if count.index < number of subnets in the role, otherwise we will get an error index out of range, use modulo to safely iterate over subnets
  subnet_id              = var.subnets_groups[each.value.subnet_role][each.value.subnet_az]
  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile   = each.value.iam_instance_profile
  key_name               = aws_key_pair.this.key_name
  /*or simply key_name   = "myapp-key" */
  user_data                   = each.value.script_name != null ? file("${path.module}/scripts/${each.value.script_name}") : null
  associate_public_ip_address = true #override map_public_ip_on_launch = true in aws_subnet.public to ensure bastion always gets a public IP even if launched in a subnet that doesnt auto-assign public IPs
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [ami]
  }

  tags = merge(
    {
      Name = "${var.full_name}-${each.key}"
      AZ   = each.value.subnet_az
    },
    var.base_tags,
    each.value.extra_tags
  )
}



resource "aws_instance" "app" {
  for_each      = var.app_instances
  ami           = data.aws_ami.this.id
  instance_type = each.value.instance_type
  #the problem with the approch below is that it works only if count.index < number of subnets in the role, otherwise we will get an error index out of range, use modulo to safely iterate over subnets
  subnet_id              = var.subnets_groups[each.value.subnet_role][each.value.subnet_az]
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = each.value.iam_instance_profile
  key_name               = aws_key_pair.this.key_name
  /*or simply key_name   = "myapp-key" */
  user_data = each.value.script_name != null ? file("${path.module}/scripts/${each.value.script_name}") : null
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [ami]
  }

  tags = merge(
    {
      Name = "${var.full_name}-${each.key}"
      AZ   = each.value.subnet_az
    },
    var.base_tags,
    each.value.extra_tags
  )
}
