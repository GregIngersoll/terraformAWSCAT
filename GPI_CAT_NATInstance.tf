# Community NAT AMI ID
data "aws_ami" "fck_nat_amzn2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["fck-nat-al2023-hvm-1.3.0-20240125-x86_64-ebs"]
  }
  filter {
    name   = "owner-id"
    values = ["568608671756"]
  }
}

# NAT Instance
resource "aws_instance" "gpi_cat_nat_instance" {
    ami = data.aws_ami.fck_nat_amzn2.id
    instance_type = var.instance_type
    key_name = data.aws_key_pair.GPI_CAT_DefaultKP.key_name

    vpc_security_group_ids = [aws_security_group.gpi_cat_nat_sg.id]
    subnet_id = aws_subnet.gpi_cat_public_vpc_public_subnets[0].id

    associate_public_ip_address = true
    source_dest_check = false

    tags = {
        Name = "nat-instance"
    }
}