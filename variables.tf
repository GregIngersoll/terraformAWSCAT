variable "private_instance_name" {
  type        = string
  default     = "GPI_CAT_PRIVATE_INSTANCE"
  description = "Name of Main EC2 Instance"
}

variable "public_instance_name" {
  type        = string
  default     = "GPI_CAT_PUBLIC_INSTANCE"
  description = "Name of Main EC2 Instance"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 Instance Type for GPI_CAT_INSTANCE"
}

variable "load_balancer_name" {
  type        = string
  default     = "GPI-CAT-LB"
  description = "Name of Main GPI_CAT LoadBalancer"
}

variable "gpi_cat_public_vpc_public_subnets" {
    type = list(string)
    default = ["10.0.101.0/24", "10.0.102.0/24"]
    description = "CIDRs for Public VPC (Public Subnets)"
}

variable "gpi_cat_public_vpc_private_subnets" {
    type = list(string)
    default = ["10.0.1.0/24", "10.0.2.0/24"]
    description = "CIDRs for Public VPC (Private Subnets)"
}

variable "azs_us_east_1" {
    type = list(string)
    default = ["us-east-1a", "us-east-1b", "us-east-1c"]
    description = "AZs for us-east-1"
}