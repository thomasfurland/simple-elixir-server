terraform {
  backend "gcs" {}
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
  name                    = "simple-elixir-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  name          = "simple-elixir-subnetwork"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_address" "static" {
  name = "simple-elixir-static-ip"
}

# firewall: allow SSH to instances with tag "allow-ssh"
resource "google_compute_firewall" "allow_ssh_ci" {
  name    = "allow-ssh-ci"
  network = google_compute_network.vpc_network.name

  direction   = "INGRESS"
  priority    = 1000
  source_ranges = ["0.0.0.0/0"] # tighten if you have fixed egress IPs
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["allow-ssh"]
}

# firewall: allow HTTP traffic to Phoenix app
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-phoenix"
  network = google_compute_network.vpc_network.name

  direction   = "INGRESS"
  priority    = 1000
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["4000"]
  }

  target_tags = ["allow-http"]
}

resource "google_compute_instance" "default" {
  name         = "simple-elixir-instance"
  machine_type = "e2-micro"
  zone         = var.zone

  tags = ["allow-ssh", "allow-http"]

  metadata = {
    enable-oslogin = "FALSE"
    ssh-keys = "ubuntu:${var.deploy_ssh_public_key}"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-minimal-2204-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
}

resource "google_sql_database_instance" "postgres" {
  name             = "simple-elixir-db"
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier = "db-f1-micro"
    
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "vm-access"
        value = google_compute_address.static.address
      }
    }
  }

  deletion_protection = false  # we tear down after done for the day.
}


resource "google_sql_database" "default" {
  name     = "appdb"
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "app" {
  name     = "appuser"
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
}

output "instance_ip" {
  description = "Public IP address of the instance"
  value       = google_compute_address.static.address
}
