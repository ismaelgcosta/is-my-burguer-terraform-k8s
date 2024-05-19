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

data "aws_cognito_user_pool_client" "is-my-burguer-auth-client" {
  client_id = data.terraform_remote_state.is-my-burguer-cognito.outputs.is-my-burguer-api-client-id
  user_pool_id = data.terraform_remote_state.is-my-burguer-cognito.outputs.cognito_id
}

data "terraform_remote_state" "is-my-burguer-cognito" {

  backend = "remote"

  config = {
    organization = "is-my-burguer"

    workspaces   = {
      name = "is-my-burguer-cognito"
    }
  }
}
