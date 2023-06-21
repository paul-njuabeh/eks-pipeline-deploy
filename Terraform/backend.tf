# local .terraform dir
.terraform/*

# lock file
.terraform.*

# tf state files
*.tfstate
*.tfstate.*
terraform {
  backend "s3" {
    bucket = "forward-project5"
    region = "us-east-2"
    key = "eks/terraform.tfstate"
  }
}