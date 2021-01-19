data "aws_iam_role" "EKS_instance_role" {
  name = "EKS_instance_role"
}

resource "aws_eks_node_group" "workers" {
  node_group_name = var.node_grp_name

  cluster_name  = var.cluster_name
  node_role_arn = data.aws_iam_role.EKS_instance_role.arn
  subnet_ids    = local.cluster_subnet_ids

  scaling_config {
    desired_size = var.ng_desired_capacity
    max_size     = var.ng_max_capacity
    min_size     = var.ng_min_capacity
  }

  ami_type        = var.ng_ami_type
  instance_types  = var.ng_instance_type

  depends_on = [
    aws_eks_cluster.demo
  ]
}
