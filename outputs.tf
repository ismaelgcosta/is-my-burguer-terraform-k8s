#################################################################################
## Cluster
#################################################################################

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  value       = module.eks.cluster_id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

#################################################################################
## Access Entry
#################################################################################

output "access_entries" {
  description = "Map of access entries created and their attributes"
  value       = module.eks.access_entries
}