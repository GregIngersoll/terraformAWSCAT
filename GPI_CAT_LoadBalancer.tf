data "aws_elb_service_account" "main" {}

resource "aws_lb" "GPI_CAT_LoadBalancer" {
  name = var.load_balancer_name

  load_balancer_type = "application"
  ip_address_type = "ipv4"

  security_groups = [aws_security_group.gpi_cat_vpc_sg.id]
  subnets         = [for subnet in aws_subnet.gpi_cat_public_vpc_public_subnets : subnet.id]

  access_logs {
    bucket = aws_s3_bucket.gpi_cat_loadbalancerlogs.id
    prefix = "GPI_CAT_LoadBalancer_access_logs"
    enabled = true
  }

  connection_logs {
    bucket = aws_s3_bucket.gpi_cat_loadbalancerlogs.id
    prefix = "GPI_CAT_LoadBalancer_connection_logs"
    enabled = true
  }
}

data "aws_lb" "GPI_CAT_LoadBalancer" {
    arn = aws_lb.GPI_CAT_LoadBalancer.arn
}

resource "aws_lb_target_group" "GPI_CAT_TargetGroupOne" {
  name = "GPI-CAT-TargetGroup"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.gpi_cat_public_vpc.id
}

resource "aws_lb_target_group_attachment" "GPI_CAT_TargetGroupOneAttachment" {
  target_group_arn = aws_lb_target_group.GPI_CAT_TargetGroupOne.arn
  target_id = aws_instance.private_app_server.id
  port = 80
}

resource "aws_lb_listener" "GPI_CAT_Listener" {
  load_balancer_arn = aws_lb.GPI_CAT_LoadBalancer.arn

  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.GPI_CAT_TargetGroupOne.arn
  }
}

