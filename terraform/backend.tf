terraform {
  backend "s3" {
    bucket = "kjfj-state"
    region = "eu-west-1"
    key = "terraform.tfstate"
  }
}
