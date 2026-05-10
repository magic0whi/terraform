output "instance_self_link" {
  value = google_compute_instance.node.self_link
}

output "instance_id" {
  value = google_compute_instance.node.instance_id
}
