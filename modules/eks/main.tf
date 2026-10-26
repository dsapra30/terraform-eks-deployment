# 1. IAM Role for EKS Cluster Control Plane
resource "aws_iam_role" "cluster" {
  name = "${var.environment}-${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# 2. Security Group for EKS Control Plane
resource "aws_security_group" "cluster_sg" {
  name        = "${var.environment}-${var.cluster_name}-cluster-sg"
  description = "EKS control plane security group"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.environment}-${var.cluster_name}-cluster-sg"
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "cluster_inbound_from_nodes" {
  description              = "Allow managed worker nodes to communicate with control plane API"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster_sg.id
  source_security_group_id = aws_security_group.node_sg.id
}

resource "aws_security_group_rule" "nodes_inbound_from_cluster" {
  description              = "Allow control plane to communicate with worker nodes (Kubelet and Pods)"
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = aws_security_group.cluster_sg.id
}

resource "aws_security_group_rule" "nodes_inbound_443_from_cluster" {
  description              = "Allow control plane to webhook extension APIs running on nodes"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = aws_security_group.cluster_sg.id
}

resource "aws_security_group_rule" "nodes_intercommunication" {
  description              = "Allow node-to-node pod networking"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = aws_security_group.node_sg.id
}


# 3. EKS Cluster Control Plane
resource "aws_eks_cluster" "this" {
  name     = "${var.environment}-${var.cluster_name}"
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.cluster_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}

# 4. IAM Role for Managed Worker Nodes
resource "aws_iam_role" "node" {
  name = "${var.environment}-${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { 
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

# 5. EKS Managed Node Group
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.environment}-managed-nodes"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids

  instance_types = var.node_instance_types

  launch_template {
    name    = aws_launch_template.node_lt.name
    version = aws_launch_template.node_lt.latest_version
  }

  scaling_config {
    desired_size = var.scaling_config.desired_size
    max_size     = var.scaling_config.max_size
    min_size     = var.scaling_config.min_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_security_group" "node_sg" {
  name        = "${var.environment}-${var.cluster_name}-node-sg"
  description = "Security group for all nodes in the EKS cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name                                                       = "${var.environment}-${var.cluster_name}-node-sg"
    "kubernetes.io/cluster/${var.environment}-${var.cluster_name}" = "owned"
    Environment                                                = var.environment
  }
}

resource "aws_launch_template" "node_lt" {
  name_prefix   = "${var.environment}-${var.cluster_name}-node-lt-"
  description   = "Launch template for EKS managed worker nodes"
  vpc_security_group_ids = [aws_security_group.node_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.environment}-eks-worker"
      Environment = var.environment
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}