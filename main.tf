locals {
  nodes = [
    {
      instance_name = "proteus-nixos-1"
      zone          = "us-central1-c"
    },
    {
      instance_name = "proteus-nixos-2"
      zone          = "europe-west10-c"
    },
    {
      instance_name = "proteus-nixos-3"
      zone          = "europe-west2-c"
    },
    {
      instance_name = "proteus-nixos-4"
      zone          = "europe-west2-c"
    },
    {
      instance_name = "proteus-nixos-5"
      zone          = "asia-east2-a"
    }
  ]
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.25.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_firewall" "allow_internal" {
  name    = "terraform-network-allow-internal"
  network = google_compute_network.vpc_network.id
  allow { protocol = "icmp" }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  source_ranges = ["10.128.0.0/9"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "terraform-network-allow-ssh"
  network = google_compute_network.vpc_network.id
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"]
}

resource "google_compute_firewall" "allow_https" {
  name    = "terraform-network-allow-https"
  network = google_compute_network.vpc_network.id
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-https"]
}

# resource "google_compute_disk" "swap_tmp" {
#   # Convert the list to a map where the key is the instance_name for for_each
#   for_each = { for node in local.nodes : node.instance_name => node }

#   name = "${each.value.instance_name}-swap-tmp"
#   type = "pd-balanced"
#   zone = each.value.zone
#   size = 10
# }

resource "google_compute_instance" "node" {
  for_each = { for node in local.nodes : node.instance_name => node }

  name         = each.value.instance_name
  machine_type = "e2-micro"
  zone         = each.value.zone
  tags         = ["allow-https", "allow-ssh"]

  allow_stopping_for_update = true
  desired_status            = "RUNNING"
  can_ip_forward            = false
  enable_display            = false
  deletion_protection       = false
  labels                    = { goog-ec-src = "vm_add-tf" }

  metadata = {
    ssh-keys = "proteus:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHBAm5d2IeApyfv8zLb7IMpex7wVHkCV86ztON7HFTkn proteus"
  }

  # attached_disk {
  #   source      = google_compute_disk.swap_tmp[each.key].id
  #   device_name = google_compute_disk.swap_tmp[each.key].name
  #   mode        = "READ_WRITE"
  # }

  boot_disk {
    auto_delete = true
    device_name = each.value.instance_name
    initialize_params {
      image = "projects/debian-cloud/global/images/debian-13-trixie-v20260310"
      size  = 30
      type  = "pd-standard"
    }
    mode = "READ_WRITE"
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_network.vpc_network.name
    access_config { network_tier = "STANDARD" }
  }

  service_account {
    email = "789759405604-compute@developer.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }
}
