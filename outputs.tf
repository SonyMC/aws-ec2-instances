# output bucket versioning info as as part of apply terraform
output "aws_security_group_http_server_details" {
  value = aws_security_group.http_server_sg
}

# output EC2 info as as part of apply terraform
output "aws_instance_http_server_details" {
  value = aws_instance.http_server
}


# output dns info as as part of apply terraform
output "http_server_public_dns_details" {
  value = aws_instance.http_server.public_dns
}


# output default vpc info as as part of apply terraform
output "aws_default_vpc_details" {
  value = aws_default_vpc.default
}

# output subnet ids info using data provider as as part of apply terraform
output "aws_subnet_ids_details" {
  value = data.aws_subnet_ids.default_subnets
}

# output aws ami info using data provider as as part of apply terraform
output "aws_ami_linux_2_details" {
  value = data.aws_ami.aws_linux_2_latest
}





