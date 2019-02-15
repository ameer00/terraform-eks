#
# Variables Configuration
#

variable "cluster-name" {
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