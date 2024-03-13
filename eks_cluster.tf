module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.2.2"

  cluster_name                   = local.name
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets
  control_plane_subnet_ids                 = module.vpc.intra_subnets
  enable_cluster_creator_admin_permissions = true

  # Temp workaround for bug : double owned tag 
  # https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1810
  node_security_group_tags = {
    "kubernetes.io/cluster/${local.name}" = null
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3.small"]
    disk_size             = 30
    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    ascode-cluster-wg = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"

      tags = {
        Example = local.name
      }
    }
  }

  tags = local.tags
}