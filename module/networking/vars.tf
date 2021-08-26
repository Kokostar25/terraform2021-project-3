
variable "cidr_block" {
    type = string
    default = "10.0.0.0/16"
}

variable "region" {
     default = "us-east-1"
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

variable "vpc_id" {
    type = string
} 


