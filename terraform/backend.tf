terraform {
  backend "s3" {
    bucket = "<your-s3-bucket>"
    region = "eu-west-1"
    key = "terraform.tfstate"
  }
}
