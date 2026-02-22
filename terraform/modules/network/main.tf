resource "aws_vpc" "this" {
    cidr_block           = var.vpc_cidr_block
    enable_dns_support   = true # allows instances to resolve internet domain names and internal aws services to IPs
    enable_dns_hostnames = true # assigns public DNS hostnames to any instance with public IP addresse
    tags                 = merge(
        {Name = "${var.full_name}-vpc"},
        var.base_tags
    )
}

resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id
    tags   = merge(
        {Name = "${var.full_name}-igw"},
        var.base_tags
    )
}

resource "aws_eip" "nat" {
#it is independent resource, dosn't need depends_on []
#each public subnet gets one EIP, which is then attached to the NAT gateway in that subnet
    for_each   = var.nat_eips
    domain     = "vpc"
    tags       = merge(
        {Name: "${var.full_name}-eip-${each.key}"
         Role = each.key
         AZ = each.value.az},
    var.base_tags,
    each.value.extra_tags
    )
}


resource "aws_nat_gateway" "this" {
#each public subnet gets one NAT gateway, which is then used as a target for the default route in the private route table for that availability zone
    for_each         = var.nat_eips
    allocation_id    = aws_eip.nat[each.key].id
    subnet_id        = aws_subnet.public[each.value.az].id
    tags             = merge(
        {Name: "${var.full_name}-nat-gw"},
        var.base_tags
    )
}


resource "aws_eip" "bastion" {
    for_each   = var.bastion_eips
    domain     = "vpc"
    tags       = merge(
        {Name: "${var.full_name}-${each.key}-eip"
         Role = "bastion"
         AZ = each.value.az},
    var.base_tags,
    each.value.extra_tags
    )
}

resource "aws_eip_association" "bastion" {
  for_each = {for name, infos in var.bastion_instances_info : name => infos if startswith(name, "bastion")}
  allocation_id = aws_eip.bastion[each.key].id
  instance_id   = each.value.id
}

resource "aws_subnet" "public" {
    for_each                = var.public_subnets #one public subnet per availability zone, using for_each to create multiple subnets based on the input variable
    vpc_id                  = aws_vpc.this.id
    cidr_block              = each.value.cidr_block
    availability_zone       = each.key
    map_public_ip_on_launch = true # auto-assign public IP to all instances launched in this subnet
    tags                    = merge({
        Name = "${var.full_name}-public-${each.key}"
        Type = "Public"
    },
    var.base_tags,
    )
}

resource "aws_route_table" "public" {
    # one route table to rule all public subnets
    vpc_id   = aws_vpc.this.id
    /*route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.this.id
   }
*/
    tags = merge({
       Name: "${var.full_name}-public-rt"
       },
       var.base_tags
    )
}

resource "aws_route" "public_internet_access" {
#using a separate route resource to add/deletes without touching the route table, to work with for_each over multiple destinations later
#in production always use separate route resource
#the local route from your vpc cidr block cidr_block= var.vpc_cidr_block is automatically created by aws and you don't need to define it in terraform, but if you want to add a specific route for that you can use the same route resource with the destination_cidr_block = var.vpc_cidr_block and gateway_id = "local"
    route_table_id         = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each       = var.public_subnets
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}


resource "aws_subnet" "private" {
    for_each                = var.private_subnets
    vpc_id                  = aws_vpc.this.id
    cidr_block              = each.value.cidr_block
    availability_zone       = each.value.availability_zone
    tags                    = merge ({
      Name = "${var.full_name}-private-${each.key}"
      Type = "Private"
    },
      var.base_tags
    )
}

resource "aws_route_table" "private" {
    for_each = var.availability_zones #one route table per availability zone, because one NAT gateway per availability zone
    vpc_id   = aws_vpc.this.id
    /* this inline route is simple and works for one route, if it changes it may cause recreation of the whole route table
     route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_nat_gateway.this[each.key].id
   }*/

    tags = merge(
       {Name: "${var.full_name}-private-rt"},
       var.base_tags
    )
}

resource "aws_route" "private_internet_access" {
#using a separate route resource to add/deletes without touching the route table, to work with for_each over multiple destinations later
#in production always use separate route resource
#the local route from your vpc cidr block cidr_block= var.vpc_cidr_block is automatically created by aws and you don't need to define it in terraform, but if you want to add a specific route for that you can use the same route resource with the destination_cidr_block = var.vpc_cidr_block and gateway_id = "local"
    for_each               = var.nat_eips
    route_table_id         = aws_route_table.private[each.value.az].id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_nat_gateway.this[each.key].id
}

resource "aws_route_table_association" "private" {
  for_each = var.private_subnets #avoid that resource driven: aws_subnet.private, insted its more senior and architectually pure to adopt input driven: var.private_subnets, 
  subnet_id      = aws_subnet.private[each.key].id
  #associate that subnet with the route table of the corresponding availability zone
  route_table_id = aws_route_table.private[each.value.availability_zone].id
}



