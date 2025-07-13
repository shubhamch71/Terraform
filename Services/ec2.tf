# key pair 

resource "aws_key_pair" "terra-key-pair" {
    key_name = "terra-key"
    public_key = file("id_ed25519.pub")
  
}

resource "aws_vpc" "my_terra_vpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
      Name = "terra-vpc"
    }
  
}

resource "aws_security_group" "my_terra_sg" {
    name = "my_sg_terra"
    description = "This sg is created using terraform"
    vpc_id = aws_vpc.my_terra_vpc.id

    tags = {
      Name = "${var.my_env}-terra-sg"
    }

   ingress {
    description = "allow port 22"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
    ipv6_cidr_blocks = ["::/0"]
   }  

    ingress {
        description = "allow prot 80"
        from_port = 80
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"
    }
    egress {
        description = "allow all out going traffic"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "-1"
    }
    ingress {
        description = "allow port 443"
        to_port = 443
        from_port = 443
        cidr_blocks = [ "0.0.0.0/0" ]
        protocol = "tcp"
    }
}

resource "aws_subnet" "my_terra_subnet" {
    vpc_id = aws_vpc.my_terra_vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-west-2a"
    map_public_ip_on_launch = true
    tags = {
        Name = "terra-subnet"
    }
  
}
resource "aws_internet_gateway" "my_terra_igw" {
  vpc_id = aws_vpc.my_terra_vpc.id

  tags = {
    Name = "terra-igw"
  }
}
resource "aws_route_table" "my_terra_rt" {
    vpc_id = aws_vpc.my_terra_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_terra_igw.id
    }
  
    tags = {
        Name ="terra-rt"
    }
}

resource "aws_route_table_association" "my_terra_rt_assocaite"  {
    subnet_id = aws_subnet.my_terra_subnet.id
    route_table_id = aws_route_table.my_terra_rt.id
    
}
# resource "aws_instance" "terra-instance" {
#     instance_type = "t2.micro"
#     key_name = aws_key_pair.terra-key-pair.key_name
#     vpc_security_group_ids  = [aws_security_group.my_terra_sg.id]
#     subnet_id = aws_subnet.my_terra_subnet.id
#     associate_public_ip_address = true
#     ami = "ami-05f991c49d264708f"
#     root_block_device {
#       volume_size = 9
#       volume_type = "gp3"
#     }
#     tags = {
#         Name = "Terra-EC2" 
#     }
# }

resource "aws_instance" "terra-instance" {
  ami                         = var.ami_id
  instance_type               = each.value
  key_name                    = aws_key_pair.terra-key-pair.key_name
  subnet_id                   = aws_subnet.my_terra_subnet.id
  vpc_security_group_ids      = [aws_security_group.my_terra_sg.id]
  associate_public_ip_address = true
  user_data = file("install_nginx.sh")
  # meta argument 
  #count = 2
  for_each = tomap({
    Sh-Terra-micro = "t2.micro"
    Sh-Terra-medium = "t2.medium"
  })

  depends_on = [ aws_security_group.my_terra_sg ]
  
  root_block_device {
    volume_size = var.my_env == "prod" ? 20 : var.default_root_block_size
    volume_type = "gp3"
  }

  tags = {
    Name = each.key
    Environment = var.my_env
  }
}


# resource "aws_instance" "sample-server" {
#   ami = "unknown"
#   instance_type = "unknown"
  
# }

# output "instance_public_ip" {
#     description = "Public IP of EC2 instance"
#     value = aws_instance.terra-instance[*].public_ip
# }

# Output block for public DNS of all instances
output "instance_public_dns" {
  description = "Public DNS names of the EC2 instances"
  value = {
    for key, instance in aws_instance.terra-instance : key => instance.public_dns
  }
}

# output "instance_public_dns" {
#     description = "Public DNS of Instance"
#     value = aws_instance.terra-instance[*].public_dns
# }

output "instance_public_ip" {
    description = "Public IP of all instances"
    value = {
        for k, instance in aws_instance.terra-instance : k => instance.public_ip
    }
  
}

