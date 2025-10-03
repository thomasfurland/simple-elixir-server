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

variable "instance_name" {
  description = "The name of the VM instance."
  type        = string
  default     = "simple-elixir-server"
}

variable "machine_type" {
  description = "The machine type of the VM instance."
  type        = string
  default     = "e2-medium"
}

variable "image_project" {
  description = "The project for the VM image."
  type        = string
  default     = "ubuntu-os-cloud"
}

variable "image_family" {
  description = "The family for the VM image."
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "db_instance_name" {
  description = "The name of the Cloud SQL instance."
  type        = string
  default     = "simple-elixir-server-db"
}

variable "db_name" {
  description = "The name of the database."
  type        = string
  default     = "simple_elixir_server_prod"
}

variable "db_user" {
  description = "The name of the database user."
  type        = string
  default     = "simple_elixir_server"
}

variable "db_password" {
  description = "The password for the database user."
  type        = string
  sensitive   = true
}

variable "artifact_registry_repository_id" {
  description = "The ID of the Artifact Registry repository."
  type        = string
  default     = "simple-elixir-server-repo"
}

variable "secret_id" {
  description = "The ID of the Secret Manager secret."
  type        = string
  default     = "simple-elixir-server-secret"
}
