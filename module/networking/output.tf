output "private_subnet_id" {
    value = aws_subnet.Prod-pri.id
}

output "public_subnet_id" {
    value = aws_subnet.Prod-pub.id
     
}