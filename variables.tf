#*** Variable declarations** 
# declare a variable to hold the path of the key-pair value 
variable "aws_key_pair" {
  default = "F:\\One Drive\\OneDrive\\Study\\DevOps\\Key-Pair\\aws\\aws_keys\\default_ec2.pem"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "aws_region" {
  default = "us-east-1"
}

