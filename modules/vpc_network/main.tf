resource "google_compute_network" "vpc_network" { name = "terraform-network" }

# In GCP, firewall rules that use target_tags only apply to VMs that have those exact same tags.
resource "google_compute_firewall" "allow_icmp" {
  name          = "terraform-network-allow-icmp"
  network       = google_compute_network.vpc_network.id
  target_tags   = ["allow-icmp"]
  source_ranges = ["0.0.0.0/0"]
  allow { protocol = "icmp" }
}

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
  target_tags   = ["allow-https"]
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

resource "google_compute_firewall" "allow_easytier" {
  name          = "terraform-network-allow-easytier"
  network       = google_compute_network.vpc_network.id
  target_tags   = ["allow-easytier"]
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["11010-11013"]
  }
  allow {
    protocol = "udp"
    ports    = ["11010-11012"]
  }
}

output "network_id" { value = google_compute_network.vpc_network.id }
output "network_name" { value = google_compute_network.vpc_network.name }
