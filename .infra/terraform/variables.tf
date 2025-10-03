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
}

variable "machine_type" {
  description = "The machine type of the VM instance."
  type        = string
}

variable "image_project" {
  description = "The project for the VM image."
  type        = string
}

variable "image_family" {
  description = "The family for the VM image."
  type        = string
}

variable "db_instance_name" {
  description = "The name of the Cloud SQL instance."
  type        = string
}

variable "db_name" {
  description = "The name of the database."
  type        = string
}

variable "db_user" {
  description = "The name of the database user."
  type        = string
}

variable "db_password" {
  description = "The password for the database user."
  type        = string
  sensitive   = true
}

variable "artifact_registry_repository_id" {
  description = "The ID of the Artifact Registry repository."
  type        = string
}

variable "secret_id" {
  description = "The ID of the Secret Manager secret."
  type        = string
}
