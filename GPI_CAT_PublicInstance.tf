

resource "aws_instance" "public_app_server" {
  ami           = data.aws_ami.ami_for_ec2.id
  instance_type = var.instance_type
  key_name = data.aws_key_pair.GPI_CAT_DefaultKP.key_name

  vpc_security_group_ids = [aws_security_group.gpi_cat_vpc_sg.id]
  subnet_id              = aws_subnet.gpi_cat_public_vpc_public_subnets[0].id

  associate_public_ip_address = true
  user_data = <<-EOF
      #!/bin/bash
      sudo yum update
      sudo yum install -y docker
      sudo service docker start 
      sudo systemctl enable docker
      sudo docker run -p 80:8080 gpingersoll/catspring 
    EOF

  tags = {
    Name = var.public_instance_name
  }
}