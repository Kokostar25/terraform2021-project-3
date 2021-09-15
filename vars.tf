variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}


variable "availability_zone" {
  type = string
}

variable "private_subnet" {
  type = string
}

variable "public_subnet" {
  type = string
}


variable "ec2_keypair" {
  default = "koko-KP"
  //   default = "A4L"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ec2_ami" {
  default = "ami-09e67e426f25ce0d7"
}
