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
    instance_types = ["t3.medium"]
    capacity_type  = "SPOT"
    disk_size             = 30
    attach_cluster_primary_security_group = true

    tags = {
      Example = local.name
    }
    
  }

  eks_managed_node_groups = {
    managed-cluster-wg = {
      min_size     = 2
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"

      tags = {
        Example = local.name
      }
    }
  }

  tags = local.tags
}

resource "kubectl_manifest" "is-my-burguer-namespace" {
  depends_on = [
    data.aws_eks_cluster.cluster
  ]
  yaml_body = <<YAML
apiVersion: apps/v1
kind: Namespace
apiVersion: v1
metadata:
  name: is-my-burguer
  namespace: is-my-burguer
  labels:
    name: is-my-burguer
    app: is-my-burguer
YAML
}

resource "kubernetes_secret" "is-my-burguer-cognito" {
  depends_on = [
    data.aws_eks_cluster.cluster
  ]

  metadata {
    name      = "is-my-burguer-cognito"
    namespace = "is-my-burguer"
  }

  immutable = false

  data = {
    user-pool-id= "${data.aws_cognito_user_pool_client.is-my-burguer-auth-client.user_pool_id}"
    api-gateway= "${data.terraform_remote_state.is-my-burguer-cognito.outputs.api_gateway_domain}"
    cognito_domain= "${data.terraform_remote_state.is-my-burguer-cognito.outputs.cognito_domain}"
    username = "${data.terraform_remote_state.is-my-burguer-cognito.outputs.is-my-burguer-api-client-id}",
    password = "${data.aws_cognito_user_pool_client.is-my-burguer-auth-client.client_secret}"
  }

  type = "kubernetes.io/basic-auth"

}