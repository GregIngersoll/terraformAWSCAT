/*module "gpi_cat_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "GPI_CAT_VPC"
  cidr = "10.0.0.0/16"

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_dns_hostnames = true
}*/
data "aws_region" "current" {}

resource "aws_vpc" "gpi_cat_public_vpc" {
    cidr_block = "10.0.0.0/16"
}

# resource "aws_vpc_ipam" "gpi_cat_vpc_ipam" {
#     operating_regions {
#         region_name = data.aws_region.current.region
#     }

# }

# resource "aws_vpc_ipam_pool" "gpi_cat_ipam_pool" {
#     address_family = "ipv6"
#     ipam_scope_id = aws_vpc_ipam.gpi_cat_ipam.private_default_scope_id
#     locale = data.aws_region.current.id
# }

# resource "aws_vpc_ipv6_cidr_block_association" "gpi_cat_public_vpc" {
#     vpc_id = aws_vpc.gpi_cat_public_vpc.id
#     ipv6_ipam_pool_id = aws_vpc_ipam_pool.gpi_cat_public_ipam_pool.id
# }

resource "aws_subnet" "gpi_cat_public_vpc_public_subnets" {
    count = length (var.gpi_cat_public_vpc_public_subnets)
    vpc_id = aws_vpc.gpi_cat_public_vpc.id
    cidr_block = element(var.gpi_cat_public_vpc_public_subnets, count.index)   

    availability_zone = element (var.azs_us_east_1, count.index)

    tags = {
        Name = "GPI_CAT Public VPC Public Subnet ${count.index + 1}"
    }
}

resource "aws_subnet" "gpi_cat_public_vpc_private_subnets" {
    count = length (var.gpi_cat_public_vpc_private_subnets)
    vpc_id = aws_vpc.gpi_cat_public_vpc.id
    cidr_block = element(var.gpi_cat_public_vpc_private_subnets, count.index)   

    availability_zone = element(var.azs_us_east_1, count.index)

    tags = {
        Name = "GPI_CAT Public VPC Private Subnet ${count.index + 1}"
    }
}

resource "aws_internet_gateway" "gpi_cat_public_vpc_igw" {
    vpc_id = aws_vpc.gpi_cat_public_vpc.id

    tags = {
        Name = "GPI_CAT Public VPC Internet GW"
    }
}

# Route Table for IGW
resource "aws_route_table" "gpi_cat_igw_rt" {
    vpc_id = aws_vpc.gpi_cat_public_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gpi_cat_public_vpc_igw.id
    }

    tags = {
        Name = "GPI_CAT Public VPC IGW Route Table"
    }
}

# Association:  Public Subnet 1 to IGW
resource "aws_route_table_association" "gpi_cat_route_table_and_igw" {
    subnet_id = aws_subnet.gpi_cat_public_vpc_public_subnets[0].id
    route_table_id = aws_route_table.gpi_cat_igw_rt.id
}

# Association:  Public Subnet 2 to IGW
resource "aws_route_table_association" "gpi_cat_rt_associate_igw" {
    subnet_id = aws_subnet.gpi_cat_public_vpc_public_subnets[1].id
    route_table_id = aws_route_table.gpi_cat_igw_rt.id
}

# Security Group for NAT Instance
resource "aws_security_group" "gpi_cat_nat_sg" {
    name = "gpi_cat_nat_sg"
    description = "Security Group for NAT Instance"
    vpc_id  = aws_vpc.gpi_cat_public_vpc.id
    tags = {
        Name = "GPI_CAT_NAT_INSTANCE_SG"
    }
}

# NAT Instance Security Group Rule to allow SSH from remote IP
resource "aws_security_group_rule" "gpi_cat_nat_instance_remote_admin" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.gpi_cat_nat_sg.id
}

# NAT Instance Security Group Rule to allow all traffic from within VPC
resource "aws_security_group_rule" "vpc_inbound" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [aws_vpc.gpi_cat_public_vpc.cidr_block]
    security_group_id = aws_security_group.gpi_cat_nat_sg.id
}

# NAT Instance Security Group Rule to allow outbound traffic
resource "aws_security_group_rule" "outbound_nat_instance" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.gpi_cat_nat_sg.id
}

# Security Group for TEST Instance
# TEST Instance Security Group Rule to allow all traffic from Public Subnet 1
# TEST Instance Security Group Rule to allow outbound access

# Route Table for NAT Instance (Private Subnet 1)
resource "aws_route_table" "gpi_cat_nat_private1" {
    vpc_id = aws_vpc.gpi_cat_public_vpc.id

    tags = {
        Name = "GPI_CAT_RT_PRIVATE1"
    }
}

# Route Table for NAT Instance (Private Subnet 2)
resource "aws_route_table" "gpi_cat_nat_private2" {
    vpc_id = aws_vpc.gpi_cat_public_vpc.id
    
    tags = {
        Name = "GPI_CAT_RT_PRIVATE2"
    }
}

# Association:  Private Subnet 1 to Route Table 1
resource "aws_route_table_association" "gpi_cat_rt_associate_nat1" {
    subnet_id = aws_subnet.gpi_cat_public_vpc_private_subnets[0].id
    route_table_id = aws_route_table.gpi_cat_nat_private1.id
}

# Association:  Private Subnet 2 to Route Table 2
resource "aws_route_table_association" "gpi_cat_rt_associate_nat2" {
    subnet_id = aws_subnet.gpi_cat_public_vpc_private_subnets[1].id
    route_table_id = aws_route_table.gpi_cat_nat_private2.id
}

# Route table entry to forward traffic to NAT Instance
resource "aws_route" "outbound-nat-route" {
    route_table_id = aws_route_table.gpi_cat_nat_private1.id
    destination_cidr_block = "0.0.0.0/0"
    network_interface_id = aws_instance.gpi_cat_nat_instance.primary_network_interface_id

}

resource "aws_security_group" "gpi_cat_vpc_sg" {
    vpc_id = aws_vpc.gpi_cat_public_vpc.id
    name = "GPI_CAT_VPC_SG"
    description = "Security Group for Web Services"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_ec2_instance_connect_endpoint" "GPI_CAT_InstanceConnectEndpoint" {
    subnet_id = aws_subnet.gpi_cat_public_vpc_private_subnets[0].id
}