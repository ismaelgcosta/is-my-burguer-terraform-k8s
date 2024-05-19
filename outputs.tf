#################################################################################
## Cluster
#################################################################################

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
  sensitive = true
}

output "cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  value       = module.eks.cluster_id
  sensitive = true
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
  sensitive = true
}

#################################################################################
## Access Entry
#################################################################################

output "access_entries" {
  description = "Map of access entries created and their attributes"
  value       = module.eks.access_entries
  sensitive = true
}

output "cluster_certificate_authority_data" {
  description = "cluster_certificate_authority_data"
  value       = module.eks.cluster_certificate_authority_data
  sensitive = true
}

