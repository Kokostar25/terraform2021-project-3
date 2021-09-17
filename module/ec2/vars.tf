variable "vpc_id" {
    type = string
  
 
}
variable "ec2_keypair" {
    default= "koko-KP"
    // default = "A4L"
}

variable "instance_type" {
    default = "t2.micro"
}

variable "ec2_ami" {
    default = "ami-09e67e426f25ce0d7"
}

variable "private_subnet" {
    type = string

}

variable "public_subnet" {
    type = string
}

variable "vpc_security_group_ids" {
    type = list(string)
}

variable "availability_zone" {
    type = string   
}

variable "subnet_id_1" {
    type = string
}

variable "subnet_id_2" {
    type = string
}

