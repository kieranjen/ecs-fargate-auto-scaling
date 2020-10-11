variable "region" {
  default = "eu-west-1"
  type = string
  description = "The region you want to deploy the infrastructure in"
}

variable "hosted_zone_id" {
  type = string
  description = "The id of the hosted zone of the Route 53 domain you want to use"
}
