resource "google_compute_network" "nopapp" {
  provider                = google.nopapp
  name                    = var.nopapp_name
  description             = "${var.nopapp_desc} VPC"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "nopapp-default" {
  provider      = google.nopapp
  name          = "${var.nopapp_name}-default"
  description   = "${var.nopapp_desc} default subnet"
  network       = google_compute_network.nopapp.self_link
  ip_cidr_range = "10.2.0.0/16"
}

