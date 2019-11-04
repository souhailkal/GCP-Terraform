resource "google_compute_network" "nopsbx" {
  name                    = var.nopsbx_name
  description             = "${var.nopsbx_desc} VPC"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "nopsbx-default" {
  name          = "${var.nopsbx_name}-default"
  description   = "${var.nopsbx_desc} default subnet"
  network       = google_compute_network.nopsbx.self_link
  ip_cidr_range = "10.3.0.0/16"
}

