# terraform {
#   backend "s3" {
#     bucket = "my-state-bucket-101"
#     key = "terraform.tfstate"
#     dynamodb_table = "remote-infra-dyanamo-db"
#     region = "us-west-2"
#   }
# }