variable "aws_region" {
  description = "AWS region where resources will be provisioned"
  default     = "us-west-2"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  default     = "ami-05f991c49d264708f"
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  default     = "t2.micro"
}

# if using for each --> If you want to define different instance types conditionally, but fall back to var.instance_type when not specified, consider doing:
# variable "instance_type_map" {
#   description = "Map of instance names to instance types"
#   type        = map(string)
#   default = {
#     Sh-Terra-micro  = "t2.micro"
#     Sh-Terra-medium = "t2.medium"
#   }
# }


# variable "my_enviroment" {
#   description = "Instance type for the EC2 instance"
#   default     = "dev"
# }

variable "my_env" {
  description = "Prod"
  default = "prod"
  type = string
  
}



variable "default_root_block_size" {
  description = "Defines the size of the root block for EC2"
  default = 9
  type = number
  
}