variable "project_id" {
  type        = string
  description = "GCP Project ID from tfvafs"
}
variable "sa_email" {
  type        = string
  description = "The service account email to associate with nodes"
}

provider "google" {
  project     = var.project_id
  credentials = file("~/.config/gcloud/project-0.secret.json")
}

locals { # Define Nodes
  nodes = [{
    name           = "proteus-nixos-0"
    zone           = "us-west1-b"
    boot_disk_name = "proteus-nixos-1"
  }]
}

module "network" { source = "../../modules/vpc_network" }

module "nodes" {
  source   = "../../modules/gce_node"
  for_each = { for n in local.nodes : n.name => n }

  project        = var.project_id
  sa_email       = var.sa_email
  name           = each.value.name
  boot_disk_name = each.value.boot_disk_name
  zone           = each.value.zone

  network_id   = module.network.network_id
  network_name = module.network.network_name
}
