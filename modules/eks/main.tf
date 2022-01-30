# Creating IAM role for Kubernetes clusters to make calls to other AWS services on your behalf to manage the resources that you use with the service.
terraform {
backend "s3" {
    bucket          = "datasaur"
    dynamodb_table  = "terraform-state-lock"
    key             = "eks.tfstate"
    region          = "ap-southeast-1"
}
}

resource "aws_iam_role" "iam-role-eks-cluster" {
name = var.iam_role
assume_role_policy = <<POLICY
{
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"Principal": {
    "Service": "eks.amazonaws.com"
},
"Action": "sts:AssumeRole"
}
]
}
POLICY
}

# Attaching the EKS-Cluster policies to the terraformekscluster role.

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.iam-role-eks-cluster.name}"
}

# # Creating the EKS cluster

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_cluster
  role_arn =  "${aws_iam_role.iam-role-eks-cluster.arn}"
  version  = "1.19"

# Adding VPC Configuration
  vpc_config {             # Configure EKS with vpc and network settings 
   security_group_ids = ["sg-023828cde7f8e56a6"]
   subnet_ids         = ["subnet-0b52b28e35dcda031","subnet-0ed5c7fc8e55d7778"] 
    }

  depends_on = [
    "aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy",
    #"aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy",
   ]
}

# Creating IAM role for EKS nodes to work with other AWS Services. 
resource "aws_iam_role" "eks_nodes" {
  name = "eks-node-group"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# # Attaching the different Policies to Node Members.

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

# # # Create EKS cluster node group

resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "node_group1"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = ["subnet-0b52b28e35dcda031","subnet-0ed5c7fc8e55d7778"]
  instance_types  = ["t2.small"]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}