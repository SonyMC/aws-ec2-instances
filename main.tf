
# Note : The Variable and Data Provider decalaraions have been moved out to separate files ( "variables.tf" and "data_providers.tf")
# ********************************************

# Provider info
provider "aws" {
  #  region  = "us-east-1"
  region  = var.aws_region # get from variable declaration above
  version = "~> 2.46"

}

# *** Get Server values from resource to avoid hardcoding 

# Get default VPC
# The following cmd will need the region to be decalred beforehand from where it will get the default vpc. In our case region is  "us-east-1"
# Note : The followign cmd does not create nor destroy a default vpc but only allows us to access/manage what is already there
resource "aws_default_vpc" "default" {

}


# ***** Define ec2 instances *****


#*********** Security Group Resource definition begins ***********

# Define Security Group
# HTTP Server -> define ports 80(TCP) for HTTP,443(TCP) for HTTPS,  22(TCP) for SSH, allow access from anywhere using CIDR block which specifies range of IP addresses CIDR["0.0.0.0/0"]

resource "aws_security_group" "http_server_sg" {
  name = "http_server_sg"
  //vpc_id = "vpc-eec60593" // Hardcoding : AWS -> services -> vpc
  vpc_id = aws_default_vpc.default.id // Default VPC access is defined above 


  # Ingress - where do we want to allow incoming traffic from 

  # HTTP Ingress 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // is a list 
  }

  # HTTPS Ingress 
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // is a list 
  }

  # SSH Ingress 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // is a list 
  }

  #what kind of things we can do from this http server
  # by default this allows access to +all systems in the internet for teh realted security group
  # however terraform disbales egress by default, and so we have to explicitly specify it in a terraform script.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"] // is a list 
  }


  # Add a tag
  tags = {
    name = "http_server_sg"
  }


}
#*********** Security Group Resource definition ends ***********


#*********** EC2 definition begins ***********
# Note : Server instances are immutable. Thsi means that we cannot modify/add/remove configurations such as connections. provisioners etc. after the EC2 instance has been created. The only way to do thsi si to destroy what has been created and run teh whole script again.

# After defining the security group above, now define the EC2 instance 
resource "aws_instance" "http_server" {
  # ami           = "ami-0947d2ba12ee1ff75" // hardcoded: get this by going through the steps of creating an EC2 instance in AWS 
  ami      = data.aws_ami.aws_linux_2_latest.id // ami id is beget from data provider defintion in the beginning 
  key_name = "default_ec2"                      // create key pair using AWS -> Services -> N/W & Security -> Key pair 
  #instance_type = "t2.micro"              // get this by going through the steps of creating an EC2 instance in AWS 
  instance_type = var.instance_type // variable declartion at top of file. get this by going through the steps of creating an EC2 instance in AWS 
  # vpc_security_group_ids = ["sg-0ccc9a679be4d5522"]    // can be found in the terraform.tfstate but hard-codign is not recommended 
  vpc_security_group_ids = [aws_security_group.http_server_sg.id] // dynamic defintion using values defined in the script above
  //subnet_id              = "subnet-05ac1c5a"                      // hardcoded:  aws -> services -> vpc ->default vpc -> subnet -> choose any available subnet 
  subnet_id = tolist(data.aws_subnet_ids.default_subnets.ids)[0] // subnet id from data provider defintion in the beginning. take first subnet id in the list we beget from the set of subnet ids

  # Connect to the server using the key-pair value "default_ec2" we have mentioned above
  connection {
    type        = "ssh"                  // type of connection we want to use is ssh
    host        = self.public_ip         // the host is what we have defined above and connect using teh public ip ( the public ip canbe found in teh details of the EC2 instance we have output)
    user        = "ec2-user"             //  this is the user that is by default created when an ec2 instance is created
    private_key = file(var.aws_key_pair) // this is the variable declared at top of file which contains path to the key pair file
  }


  # Now mention what all needs to be executed on the newly created EC2 server. The below shows how to copy a message into an html file  
  provisioner "remote-exec" {
    // type in all the commands to be executed inline
    inline = [
      // install http server
      "sudo yum install httpd -y",
      // start the server
      "sudo service httpd start",
      // echo a message and copy it into a file; print the message into index.html; Note: the apostrophe is treated a cmd character and if used in echo it will fail
      //"echo Welcome to in28minutes - Virtual Server is at ${self.public_dns} | sudo tee /var/www/html/index.html"
      "echo Welcome to world of Sony - Virtual Server is at ${self.public_dns} | sudo tee /var/www/html/index.html"
    ]

  }


}


