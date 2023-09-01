terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.9"
    }
  }
  /*backend "s3" {
  bucket = geopellcloud.net
  key = AWS/terraform-tfstate
  region = us-east-1
  dynamodb_table=terraform-state
 }*/

}
/*#Using Variable
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = us-east-1
}
*/
# Configure the AWS Provider
provider "aws" {
#  region = var.aws_region
  region = "us-east-1"
  access_key = "AKIAIVKYEQBHYT24WJBQ"
  secret_key = "HJd1SbIqmy2WHOErRUNHONYPo89rEHeyZjIDKzCH"
 
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-example"
  }
}
# Create a Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.0.0/20"
  #cidr_block        = var.vpc_cidr_block
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf-example"
  }
}

# Create my first terraform instance
resource "aws_instance" "my_instance"  {
  ami           = "ami-0dba2cb6798deb6d8" # us-east-1
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_web.id]
  user_data              = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2
              sed -i -e 's/80/8080/' /etc/apache2/ports.conf
              echo "Terraform and Devops are the best" > /var/www/html/index.html
              systemctl restart apache2
              EOF         

  tags = {
    Name = "HelloWorld"
  }
   # This will create 1 instances
  count = 2

}
resource "aws_security_group" "sg_web" {
  name = "sg_web"
  ingress {
    from_port   = "8080"
    to_port     = "8080"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // connectivity to ubuntu mirrors is required to run `apt-get update` and `apt-get install apache2`
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    lifecycle {
    ignore_changes = [
    ]
  }
}


#create s3 bucket
/*resource "aws_s3_bucket" "tf-example" {
  bucket = "paschal-test-bucket"

  tags = {
    Name        = "tf-bucket"
    Environment = "Dev"
  }
}

#Using s3 module
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "paschal-module-bucket"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}
*/
# Create jenkins instance
resource "aws_instance" "jenkins"  {
  ami           = "ami-005f9685cb30f234b" # us-east-1
  instance_type = "t2.micro"
  tags = {
    Name = "Jenkins"
  }
}
