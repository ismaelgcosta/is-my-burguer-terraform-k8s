provider "aws" {
  region = local.region
}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.cluster.token
}

terraform {
  cloud {
    organization = "is-my-burguer"

    workspaces {
      name = "is-my-burguer-k8s"
    }
  }

  required_providers {
    aws = {
      version = "~> 5.38.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.26.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}
