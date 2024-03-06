variable "postgres_user" {
  description = "The master username for the database."
  type        = string
  sensitive   = true
}

variable "postgres_password" {
  description = "The master password for the database."
  type        = string
  sensitive   = true
}