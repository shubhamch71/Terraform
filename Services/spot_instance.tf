# # Terraform configuration for creating an AWS Spot Instance


# # Data source to fetch the latest Amazon Linux 2 AMI
# data "aws_ami" "amazon_linux" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

# # Create a VPC
# resource "aws_vpc" "my_terra_vpc" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_support   = true
#   enable_dns_hostnames = true

#   tags = {
#     Name = "Terra-VPC"
#   }
# }

# # Create a subnet
# resource "aws_subnet" "my_terra_subnet" {
#   vpc_id                  = aws_vpc.my_terra_vpc.id
#   cidr_block              = "10.0.1.0/24"
#   availability_zone       = "us-east-1a" # Replace with your preferred AZ
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "Terra-Public-Subnet"
#   }
# }

# # Create an internet gateway
# resource "aws_internet_gateway" "my_terra_igw" {
#   vpc_id = aws_vpc.my_terra_vpc.id

#   tags = {
#     Name = "Terra-Internet-Gateway"
#   }
# }

# # Create a route table
# resource "aws_route_table" "my_terra_route_table" {
#   vpc_id = aws_vpc.my_terra_vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.my_terra_igw.id
#   }

#   tags = {
#     Name = "Terra-Route-Table"
#   }
# }

# # Associate route table with subnet
# resource "aws_route_table_association" "my_terra_route_assoc" {
#   subnet_id      = aws_subnet.my_terra_subnet.id
#   route_table_id = aws_route_table.my_terra_route_table.id
# }

# # Create a security group
# resource "aws_security_group" "my_terra_sg" {
#   vpc_id      = aws_vpc.my_terra_vpc.id
#   name        = "terra-sg"
#   description = "Security group for Spot Instance"

#   # Allow SSH access
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # Restrict to your IP for better security
#   }

#   # Allow outbound traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "Terra-Security-Group"
#   }
# }

# # Create a key pair (replace public_key with your actual SSH public key)
# resource "aws_key_pair" "terra_key_pair" {
#   key_name   = "terra-key-pair"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3...your-public-key..." # Replace with your SSH public key
# }

# # Create the Spot Instance
# resource "aws_instance" "spot_instance" {
#   ami                         = data.aws_ami.amazon_linux.id
#   instance_type               = "t3.micro"
#   subnet_id                   = aws_subnet.my_terra_subnet.id
#   vpc_security_group_ids      = [aws_security_group.my_terra_sg.id]
#   key_name                    = aws_key_pair.terra_key_pair.key_name
#   associate_public_ip_address = true

#   instance_market_options {
#     market_type = "spot"

#     spot_options {
#       max_price                      = "0.0100"      # Optional: Adjust based on region (e.g., $0.01/hour for t3.micro)
#       spot_instance_type             = "one-time"    # Use "persistent" for auto-restart after interruption
#       instance_interruption_behavior = "terminate"   # Options: "terminate", "stop", or "hibernate"
#     }
#   }

#   root_block_device {
#     volume_size           = 10
#     volume_type           = "gp3"
#     delete_on_termination = true
#   }

#   # Optional: User data for instance initialization
#   user_data = <<-EOF
#     #!/bin/bash
#     yum update -y
#     echo "Spot instance initialized" > /tmp/init.log
#   EOF

#   tags = {
#     Name = "Terra-Spot-Instance"
#   }
# }