#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "eks" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
     "Name", "terraform-eks-node",
     "kubernetes.io/cluster/${var.cluster_name}", "shared",
    )
  }"
}

resource "aws_subnet" "eks" {
  count = "${var.num_nodes}"

  availability_zone = "${data.aws_availability_zones.available.names[count.index%2]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.eks.id}"

  tags = "${
    map(
     "Name", "terraform-eks-node",
     "kubernetes.io/cluster/${var.cluster_name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "eks" {
  vpc_id = "${aws_vpc.eks.id}"

  tags {
    Name = "terraform-eks"
  }
}

resource "aws_route_table" "eks" {
  vpc_id = "${aws_vpc.eks.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.eks.id}"
  }
}

resource "aws_route_table_association" "eks" {
  count = "${var.num_nodes}"

  subnet_id      = "${aws_subnet.eks.*.id[count.index]}"
  route_table_id = "${aws_route_table.eks.id}"
}
