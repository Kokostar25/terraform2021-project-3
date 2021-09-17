resource "aws_instance" "Prod-pub-EC2" {
     
    ami         = var.ec2_ami
    instance_type = var.instance_type
    key_name = var.ec2_keypair
    subnet_id = var.subnet_id_1
    vpc_security_group_ids = [aws_security_group.prod-public-sg.id]
    availability_zone = var.availability_zone
    associate_public_ip_address = true
    user_data = <<-EOF
            #! /bin/bash
            sudo apt-get update -y
            sudo apt-get upgrade -y
            sudo apt-get install apache2 -y
            sudo systemctl start apache2 
            sudo chmod +x /var/www/html/index.html
            sudo bash -c 'echo Deployed via Terraform > /var/www/html/index.html'
            EOF
    
  tags = {
    Name = "koko-pub-EC2 -${(var.availability_zone)}"
  }
}


resource "aws_instance" "Prod-pri-EC2" {
    ami           = var.ec2_ami
    instance_type = var.instance_type
    key_name = var.ec2_keypair
    subnet_id = var.subnet_id_2
    vpc_security_group_ids = [aws_security_group.prod-private-sg.id]
    availability_zone = var.availability_zone
    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
    associate_public_ip_address = false
  
    
  
    tags = {
    Name = "koko-pri-EC2 -${(var.availability_zone)}"
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2roleforssm"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
      "Effect": "Allow",
      "Principal": {"Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  }
EOF
}

resource "aws_iam_role_policy_attachment" "ec2policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}


# Create Security group

resource "aws_security_group" "prod-public-sg" {
  name        = "koko-public-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "inbound rules from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] 
  }
    
 ingress {
    description      = "inbound rules from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }  

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }    
  
}

resource "aws_security_group" "prod-private-sg" {
  name        = "koko-private-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  

}

# Internet Gateway

resource "aws_internet_gateway" "Prod-gw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "Prod-gw"
  }
}

resource "aws_nat_gateway" "koko-nat-gw" {
  
  allocation_id = aws_eip.prod-natgw-eip.id
  subnet_id = var.subnet_id_1
  
  tags = {
    Name = "prod-nat-gw"
  }
}

# Elastic IP

resource "aws_eip" "prod-natgw-eip" {
  vpc           = true
  depends_on    = [aws_internet_gateway.Prod-gw]

  tags = {
    Name = "prod-eip"
    }
}



# Public Route Table

resource "aws_route_table" "prod-PublicRT" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Prod-gw.id

  }

    tags = {
    Name = "prod-PublicRT"
    }
}

# Private Route Table

resource "aws_route_table" "prod-PrivateRT" {
  vpc_id          = var.vpc_id
  route {
    cidr_block    = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.koko-nat-gw.id
    
   }
tags = {
    Name = "prod-PrivateRT"
    }
}
# Route Table Association

resource "aws_route_table_association" "koko-PubRT" {
  subnet_id       = var.subnet_id_1
  route_table_id  = aws_route_table.prod-PublicRT.id
}


resource "aws_route_table_association" "koko-PriRT" {
  subnet_id        = var.subnet_id_2
  route_table_id   = aws_route_table.prod-PrivateRT.id
}