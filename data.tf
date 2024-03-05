data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  depends_on = [module.eks]
  name       = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  depends_on = [data.aws_eks_cluster.cluster]
  name       = module.eks.cluster_name
}

data "terraform_remote_state" "is-my-burguer-postgres" {
  backend = "remote"

  config = {
    organization = "is-my-burguer"
    workspaces = {
      name = "is-my-burguer-postgres"
    }
  }
}
