provider "aws" {
  region = var.region # Modify this as per your needs
}

variable "region" {
  default = "ap-southeast-1"
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}
