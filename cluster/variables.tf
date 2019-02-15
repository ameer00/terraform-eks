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