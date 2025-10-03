terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc_network" {
  name                    = "simple-elixir-server-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  name          = "simple-elixir-server-subnetwork"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_address" "static" {
  name = "simple-elixir-server-static-ip"
}

resource "google_compute_instance" "default" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "${var.image_project}/${var.image_family}"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
}

resource "google_sql_database_instance" "default" {
  name             = var.db_instance_name
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = "db-g1-small"
  }
}

resource "google_sql_database" "default" {
  name     = var.db_name
  instance = google_sql_database_instance.default.name
}

resource "google_sql_user" "default" {
  name     = var.db_user
  instance = google_sql_database_instance.default.name
  password = var.db_password
}

resource "google_artifact_registry_repository" "default" {
  location      = var.region
  repository_id = var.artifact_registry_repository_id
  format        = "DOCKER"
}

resource "google_secret_manager_secret" "default" {
  secret_id = var.secret_id

  replication {
    automatic = true
  }
}
