# *** Get definitions of AWS resources using data providers 

# Get subnet ids using data providers 
data "aws_subnet_ids" "default_subnets" {
  vpc_id = aws_default_vpc.default.id // specify which vpc to get the subnetss for 

}

# Get latest AMI id using data providers 
data "aws_ami" "aws_linux_2_latest" {
  most_recent = true       // get latest
  owners      = ["amazon"] // use only amazon provided images ; better to stay away from other manufacturers
  // use linux 2 by applying a filter
  filter {
    name   = "name"              // filter on attribute name having values similar to what is defined below
    values = ["amzn2-ami-hvm-*"] // value neds to be provided as a list
  }

}

# We need the below AMI as teh above query expects back only one result whereas we will get many.
data "aws_ami_ids" "aws_linux_2_latest_ids" {
  owners = ["amazon"] // use only amazon provided images ; better to stay away from other manufacturers
}


