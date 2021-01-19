data "aws_iam_role" "EKS_cluster_role" {
  name = "EKS_cluster_role"
}

data "aws_vpc"	"existing_vpc"{
	id = var.existing_vpc_id
}

data "aws_subnet_ids" "existing_subnet_id" {
  vpc_id = var.existing_vpc_id
}

locals {
  cluster_security_group_id         = var.cluster_create_security_group ? join("", aws_security_group.cluster.*.id) : var.cluster_security_group_id
  cluster_vpc_id = var.create_vpc ? aws_vpc.this[0].id : data.aws_vpc.existing_vpc.id
  cluster_subnet_ids = var.create_vpc ? aws_subnet.public[*].id : data.aws_subnet_ids.existing_subnet_id.ids
}




resource "aws_security_group" "cluster" {
  name        = "terraform-eks-demo-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = local.cluster_vpc_id

  tags = {
    Name = "terraform-eks-demo"
  }
}

resource "aws_security_group_rule" "cluster_egress_internet" {
  count             = var.cluster_create_security_group && var.create_eks ? 1 : 0
  description       = "Allow cluster egress access to the Internet."
  protocol          = "-1"
  security_group_id = local.cluster_security_group_id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "demo-cluster-ingress" {
  from_port         = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = local.cluster_security_group_id
  to_port           = 0
  type              = "ingress"
  depends_on = [
    aws_security_group.cluster
  ]
}

resource "aws_eks_cluster" "demo" {
  count                     = var.create_eks ? 1 : 0
  name                      = var.cluster_name
  role_arn                  = data.aws_iam_role.EKS_cluster_role.arn
  version                   = var.cluster_version
  tags                      = var.eks_tags

  vpc_config {
    security_group_ids      = compact([local.cluster_security_group_id])
    subnet_ids              = local.cluster_subnet_ids
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  depends_on = [
    aws_security_group.cluster,
    aws_vpc.this[0]
  ]
}
