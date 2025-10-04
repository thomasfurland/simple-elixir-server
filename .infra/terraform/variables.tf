variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The GCP region."
  type        = string
}

variable "zone" {
  description = "The GCP zone."
  type        = string
}

variable "db_password" {
  description = "The password for the database user."
  type        = string
  sensitive   = true
}

variable "deploy_ssh_public_key" {
  description = "SSH public key for deployment access"
  type        = string
  sensitive   = true
}
