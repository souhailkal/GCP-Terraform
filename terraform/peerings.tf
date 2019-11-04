# Create peerings between operations and applications networks.

# https://www.terraform.io/docs/providers/google/r/compute_network_peering.html

resource "google_compute_network_peering" "prdops-to-prdapp" {
  provider           = google.prdops
  name               = "${var.prdops_name}-to-${var.prdapp_name}"
  network            = google_compute_network.prdops.self_link
  peer_network       = google_compute_network.prdapp.self_link
  auto_create_routes = true
}

resource "google_compute_network_peering" "prdapp-to-prdops" {
  provider           = google.prdapp
  name               = "${var.prdapp_name}-to-${var.prdops_name}"
  network            = google_compute_network.prdapp.self_link
  peer_network       = google_compute_network.prdops.self_link
  auto_create_routes = true
  depends_on         = [google_compute_network_peering.prdops-to-prdapp]
}

resource "google_compute_network_peering" "prdops-to-nopapp" {
  provider           = google.prdops
  name               = "${var.prdops_name}-to-${var.nopapp_name}"
  network            = google_compute_network.prdops.self_link
  peer_network       = google_compute_network.nopapp.self_link
  auto_create_routes = true
  depends_on         = [google_compute_network_peering.prdapp-to-prdops]
}

resource "google_compute_network_peering" "nopapp-to-prdops" {
  provider           = google.nopapp
  name               = "${var.nopapp_name}-to-${var.prdops_name}"
  network            = google_compute_network.nopapp.self_link
  peer_network       = google_compute_network.prdops.self_link
  auto_create_routes = true
  depends_on         = [google_compute_network_peering.prdops-to-nopapp]
}

