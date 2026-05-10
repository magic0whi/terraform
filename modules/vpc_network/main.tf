resource "google_compute_network" "vpc_network" { name = "terraform-network" }

resource "google_compute_firewall" "allow_internal" {
  name          = "terraform-network-allow-internal"
  network       = google_compute_network.vpc_network.id
  source_ranges = ["10.128.0.0/9"]
  allow { protocol = "icmp" }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
}

resource "google_compute_firewall" "allow_ssh" {
  name          = "terraform-network-allow-ssh"
  network       = google_compute_network.vpc_network.id
  target_tags   = ["allow-ssh"]
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "allow_https" {
  name          = "terraform-network-allow-https"
  network       = google_compute_network.vpc_network.id
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-https"]
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

output "network_id" { value = google_compute_network.vpc_network.id }
output "network_name" { value = google_compute_network.vpc_network.name }
