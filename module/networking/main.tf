# Create a VPC

resource "aws_vpc" "Prod-vpc" {
cidr_block = var.cidr_block
enable_dns_support = true
enable_dns_hostnames = true

tags = {
    Name = "Prod-vpc"
    }

}


output "Prod-vpc_id" {
    value = aws_vpc.Prod-vpc.id
}


# Create Subnets
resource "aws_subnet" "Prod-pub" {
  vpc_id    =   var.vpc_id
  cidr_block = var.public_subnet
  availability_zone = var.availability_zone
   map_public_ip_on_launch = true

  tags = {
    Name = "koko-pub - ${(var.availability_zone)}"
  }
}


resource "aws_subnet" "Prod-pri" {
  vpc_id    =  var.vpc_id 
  cidr_block = var.private_subnet
  availability_zone = var.availability_zone
  map_public_ip_on_launch = false 

  tags = {
    Name = "koko-pri- ${(var.availability_zone)}"
  }
}