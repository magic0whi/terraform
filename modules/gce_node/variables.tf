variable "project" {
  type        = string
  description = "The GCP project ID"
}

variable "name" {
  type        = string
  description = "The name of the node"
}
variable "boot_disk_name" {
  type        = string
  description = "The name of the boot disk"
}
variable "zone" {
  type        = string
  description = "The zone for the node"
}

variable "ssh_keys" {
  type        = string
  description = "SSH keys to add to the instance metadata"
  default     = "proteus:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHBAm5d2IeApyfv8zLb7IMpex7wVHkCV86ztON7HFTkn proteus"
}

variable "sa_email" {
  type        = string
  description = "The service account email to associate with the instance"
}
