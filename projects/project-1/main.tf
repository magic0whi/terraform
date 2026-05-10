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
  credentials = file("~/.config/gcloud/project-1.secret.json")
}

# Define Nodes
locals {
  nodes = [
    {
      name = "proteus-nixos-1"
      zone = "us-central1-c"
    },
    {
      name = "proteus-nixos-2"
      zone = "europe-west10-c"
    },
    {
      name = "proteus-nixos-3"
      zone = "europe-west2-c"
    },
    {
      name = "proteus-nixos-4"
      zone = "europe-west2-c"
    },
    {
      name = "proteus-nixos-5"
      zone = "asia-east2-a"
    }
  ]
}

module "network" { source = "../../modules/vpc_network" }

module "nodes" {
  source   = "../../modules/gce_node"
  for_each = { for n in local.nodes : n.name => n }

  project        = var.project_id
  sa_email       = var.sa_email
  name           = each.value.name
  boot_disk_name = each.value.name
  zone           = each.value.zone

  network_id   = module.network.network_id
  network_name = module.network.network_name
}
