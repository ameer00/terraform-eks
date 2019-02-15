#
# Variables Configuration
#

variable "cluster_name" {
  default = "eks-1"
  type    = "string"
}

variable "num_nodes" {
    default = 4
}

variable "aws_region" {
    default = "us-east-1"
    type = "string"
}

/*
variable "aws_access_key" {
    type = "string"
}

variable "aws_secret_key" {
    type = "string"
}
*/